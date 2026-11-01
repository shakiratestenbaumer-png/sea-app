from pydantic import BaseModel


class ErrorResponse(BaseModel):
    code: str
    message: str
    request_id: str | None = None
    details: dict | None = None


class PaginatedResponse(BaseModel):
    items: list
    total: int
    page: int
    per_page: int
    has_next: bool
