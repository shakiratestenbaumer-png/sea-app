import time
import uuid

import httpx
import jwt
from fastapi import APIRouter, Depends, Header, HTTPException
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import AuthBootstrap, AuthResponse as BootstrapAuthResponse

router = APIRouter(prefix="/auth", tags=["auth"])

NULLLINK_VAULT_URL = "https://nulllink.ch"
JWT_SECRET = settings.jwt_secret_key
JWT_ALGORITHM = settings.jwt_algorithm
JWT_EXPIRY_HOURS = 720  # 30 days

# In-memory user store for NullLink sessions (later: PostgreSQL)
_users: dict[str, dict] = {}


class ChallengeRequest(BaseModel):
    nlid: str


class ChallengeResponse(BaseModel):
    challenge_id: str
    nonce: str
    expires_in: int


class VerifyRequest(BaseModel):
    challenge_id: str
    nlid: str
    signature: str


class NulllinkAuthResponse(BaseModel):
    token: str
    nlid: str
    is_new_user: bool


@router.post("/bootstrap", response_model=BootstrapAuthResponse)
async def bootstrap_user(body: AuthBootstrap, db: AsyncSession = Depends(get_db)):
    """Create or retrieve a user account and return an access token."""
    from app.core.security import create_access_token

    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()

    if not user:
        user = User(email=body.email, locale=body.locale)
        db.add(user)
        await db.flush()

    token = create_access_token({"sub": str(user.id), "email": user.email})
    return BootstrapAuthResponse(
        access_token=token,
        user_id=str(user.id),
        email=user.email,
    )


@router.post("/challenge", response_model=ChallengeResponse)
async def create_challenge(req: ChallengeRequest):
    """Create an authentication challenge via NullLink vault."""
    async with httpx.AsyncClient(timeout=10) as client:
        resp = await client.post(
            f"{NULLLINK_VAULT_URL}/api/auth/challenge",
            json={"nlid": req.nlid},
        )
        if resp.status_code != 200:
            raise HTTPException(502, f"NullLink vault error: {resp.status_code}")
        data = resp.json()
        return ChallengeResponse(
            challenge_id=data["challengeId"],
            nonce=data["nonce"],
            expires_in=data.get("expiresIn", 300),
        )


@router.post("/verify", response_model=NulllinkAuthResponse)
async def verify_challenge(req: VerifyRequest):
    """Verify a signed challenge and issue a JWT."""
    async with httpx.AsyncClient(timeout=10) as client:
        resp = await client.post(
            f"{NULLLINK_VAULT_URL}/api/auth/verify",
            json={
                "challengeId": req.challenge_id,
                "nlid": req.nlid,
                "signature": req.signature,
            },
        )
        if resp.status_code != 200:
            raise HTTPException(401, "Challenge verification failed")
        data = resp.json()
        if not data.get("verified"):
            raise HTTPException(401, "Signature not verified")

    is_new = req.nlid not in _users
    if is_new:
        _users[req.nlid] = {
            "nlid": req.nlid,
            "public_key": data.get("publicKey"),
            "created_at": time.time(),
            "last_seen": time.time(),
        }
    else:
        _users[req.nlid]["last_seen"] = time.time()

    token = jwt.encode(
        {
            "sub": req.nlid,
            "iat": int(time.time()),
            "exp": int(time.time() + JWT_EXPIRY_HOURS * 3600),
            "jti": str(uuid.uuid4()),
        },
        JWT_SECRET,
        algorithm=JWT_ALGORITHM,
    )

    return NulllinkAuthResponse(token=token, nlid=req.nlid, is_new_user=is_new)


async def get_nulllink_user(authorization: str | None = Header(default=None)):
    if not authorization or not authorization.startswith("Bearer "):
        return None
    try:
        payload = jwt.decode(
            authorization[7:],
            JWT_SECRET,
            algorithms=[JWT_ALGORITHM],
        )
        nlid = payload.get("sub")
        if not isinstance(nlid, str):
            return None
        return _users.get(nlid)
    except jwt.ExpiredSignatureError:
        raise HTTPException(401, "Token expired") from None
    except jwt.InvalidTokenError:
        return None


@router.get("/me")
async def get_me(user=Depends(get_nulllink_user)):
    if not user:
        raise HTTPException(401, "Not authenticated")
    return {"nlid": user["nlid"], "created_at": user["created_at"]}


@router.get("/providers")
async def auth_providers():
    return {
        "providers": [
            {
                "id": "nulllink",
                "name": "NullLink ID",
                "vault_url": NULLLINK_VAULT_URL,
                "status": "active",
                "description": "Zero-knowledge authentication",
            }
        ]
    }
