# 005 — Google Play Store Publishing Guide

**Version:** 1.0
**Date:** 1 November 2026
**Project:** Swiss Energy Assistant (SEA)

---

## Table of Contents

1. [Pre-Publication Checklist](#1-pre-publication-checklist)
2. [Google Play Console Setup](#2-google-play-console-setup)
3. [App Listing Details](#3-app-listing-details)
4. [Pricing & Monetization](#4-pricing--monetization)
5. [APK/AAB Upload](#5-apkaab-upload)
6. [Store Screenshots](#6-store-screenshots)
7. [Content Rating](#7-content-rating)
8. [Privacy Policy](#8-privacy-policy)
9. [Review & Launch](#9-review--launch)
10. [iOS App Store (Separate Mac Required)](#10-ios-app-store)

---

## 1. Pre-Publication Checklist

- [x] Release APK built: `mobile/build/app/outputs/flutter-apk/app-release.apk` (58 MB)
- [x] App icon: Custom Swiss Energy Clock icon (1254×1254 source)
- [x] Trilingual (DE/EN/FR) with system language detection
- [x] All text properly translated
- [x] Plotly charts working with pinch-to-zoom
- [x] Real API data from 3 Swiss providers
- [x] Onboarding flow complete
- [ ] **Privacy policy page** (create at https://sea.supercharged.ch/privacy)
- [ ] **Google Play Console account** ($25 one-time fee)
- [ ] **App signing key** (use Play App Signing — recommended)

## 2. Google Play Console Setup

### Step 1: Create Developer Account
1. Go to https://play.google.com/console/signup
2. Pay the **$25 one-time registration fee**
3. Complete identity verification (takes 24-48h for personal accounts)

### Step 2: Create App
1. Click **"Create app"**
2. Fill in:
   - **App name:** Swiss Energy Assistant
   - **Default language:** German (de) — since CH is German-majority
   - **App or game:** App
   - **Free or paid:** Free (with in-app subscriptions)
3. Accept declarations

### Step 3: Build AAB (Android App Bundle) — Preferred over APK

```bash
cd /home/yomo/mub/projects/experiment/ems/mobile
flutter build appbundle --release
```

The AAB will be at: `build/app/outputs/bundle/release/app-release.aab`

> **Note:** Google Play prefers AAB over APK. AAB allows Google to optimize delivery per device.

## 3. App Listing Details

### Store Listing (German — Default)

**App-Name:** Swiss Energy Assistant

**Kurzbeschreibung (80 Zeichen):**
> Dynamische Strompreise vergleichen & günstigste Zeiten für Geräte finden.

**Ausführliche Beschreibung:**
> Swiss Energy Assistant zeigt Ihnen in Echtzeit die aktuellen dynamischen Strompreise der Schweizer Anbieter CKW, Groupe E und Primeo. Finden Sie den günstigsten Zeitpunkt für Ihre Haushaltsgeräte und sparen Sie CHF 50–200 pro Jahr.
>
> ⚡ FUNKTIONEN:
> • Echtzeit-Strompreise von 3 Schweizer Anbietern (15-Minuten-Auflösung)
> • Empfehlung für günstigste Laufzeit (Waschmaschine, Geschirrspüler, E-Auto, etc.)
> • Interaktive Preischarts mit Plotly (Pinch-to-Zoom)
> • Anbietervergleich mit Box-Plot-Darstellung
> • Sparpotenzial-Berechnung für alle Ihre Geräte
> • Dreisprachig: Deutsch, Englisch, Französisch
>
> 🇨🇭 SCHWEIZ-SPEZIFISCH:
> • CKW (Luzern/Zentralschweiz)
> • Groupe E (Fribourg/Westschweiz)
> • Primeo Energie (Basel/Nordwestschweiz)
> • SmartGridready-kompatibel
> • CHF-Preise in Rp./kWh
>
> 💡 SO SPAREN SIE:
> Dynamische Stromtarife variieren über den Tag. Wer die Waschmaschine um 03:00 statt um 18:00 laufen lässt, spart bis zu 50% der Energiekosten pro Waschgang.
>
> 🔒 DATENSCHUTZ:
> Keine Registrierung erforderlich. Alle Daten bleiben lokal auf Ihrem Gerät. Keine persönlichen Daten werden gesammelt.

### Store Listing (English)

**Short description:**
> Compare dynamic electricity prices & find the cheapest time for your appliances.

**Full description:**
> Swiss Energy Assistant shows you real-time dynamic electricity prices from Swiss providers CKW, Groupe E, and Primeo. Find the cheapest time to run your appliances and save CHF 50–200 per year.
>
> ⚡ FEATURES:
> • Real-time electricity prices from 3 Swiss providers (15-minute resolution)
> • Optimal run-time recommendations (dishwasher, washer, EV charger, etc.)
> • Interactive price charts with Plotly (pinch-to-zoom)
> • Provider comparison with box plots
> • Savings estimate for all your appliances
> • Trilingual: German, English, French
>
> 🇨🇭 SWISS-SPECIFIC:
> • CKW (Lucerne/Central Switzerland)
> • Groupe E (Fribourg/Western Switzerland)
> • Primeo Energie (Basel/Northwestern Switzerland)
>
> 💡 HOW YOU SAVE:
> Dynamic tariffs vary throughout the day. Running your washing machine at 3 AM instead of 6 PM can save up to 50% on energy costs per cycle.

### Store Listing (French)

**Brève description:**
> Comparez les prix dynamiques de l'électricité et trouvez les meilleurs créneaux.

**Description détaillée:**
> Swiss Energy Assistant affiche en temps réel les prix dynamiques de l'électricité des fournisseurs suisses CKW, Groupe E et Primeo. Trouvez le meilleur moment pour vos appareils et économisez CHF 50–200 par an.

## 4. Pricing & Monetization

### Recommended Model

| Tier | Price | What's Included |
|------|-------|----------------|
| **Free** | CHF 0 | View prices, add appliances, see savings estimates |
| **Premium** | CHF 1.50/month or CHF 10/year | Push notifications, daily digest, quiet hours, priority data refresh |

### Play Store Setup
1. Go to **Monetize → Subscriptions**
2. Create subscription product:
   - **Product ID:** `sea_premium`
   - **Name:** Swiss Energy Premium
   - **Base plans:**
     - Monthly: CHF 1.50/month
     - Annual: CHF 10.00/year (label as "Save 44%")
3. **Free trial:** 30 days (first month free)
4. **Grace period:** 3 days

### Implementation Note
The subscription paywall is not yet implemented in the app. For the initial release, the app is **fully free**. Add the subscription later once you have users providing feedback on what they'd pay for.

> **Recommendation:** Launch as FREE first to build a user base and ratings. Add the paywall in v1.1 after 500+ installs.

## 5. APK/AAB Upload

### Build AAB
```bash
cd /home/yomo/mub/projects/experiment/ems/mobile
flutter build appbundle --release
```

### Upload
1. Go to **Release → Production** (or Internal Testing first)
2. Click **"Create new release"**
3. Upload `app-release.aab`
4. Add release notes:
   ```
   v1.0.0 — Initial release
   • Real-time dynamic electricity prices from CKW, Groupe E, and Primeo
   • Optimal appliance scheduling with savings calculator
   • Interactive Plotly charts with pinch-to-zoom
   • Trilingual: German, English, French
   • Swiss PLZ auto-lookup
   ```

### Recommended: Start with Internal Testing
1. First upload to **Internal testing** track
2. Add your email as a tester
3. Install via Play Store link
4. If everything works, promote to **Production**

## 6. Store Screenshots

You need:
- **Phone screenshots:** At least 2, up to 8 (1080×1920 or similar)
- **Feature graphic:** 1024×500 px

Take screenshots on your CPH2307 phone:
```bash
adb exec-out screencap -p > screenshot_overview.png
# Navigate to different screens and take more
adb exec-out screencap -p > screenshot_chart.png
adb exec-out screencap -p > screenshot_compare.png
adb exec-out screencap -p > screenshot_appliances.png
```

### Recommended Screens to Capture
1. **Overview** — Hero card + chart visible
2. **Price chart** — Zoomed in, showing all 3 providers
3. **Comparison** — Box plot with all providers
4. **Appliances** — Cards with savings estimates
5. **Onboarding** — Language selection step

## 7. Content Rating

Fill out the **IARC questionnaire** in Play Console:
- Violence: None
- Sexual content: None
- Language: None
- Controlled substances: None
- User interaction: None (no user-to-user features)
- Data sharing: No personal data shared

Expected rating: **PEGI 3 / Everyone**

## 8. Privacy Policy

Create at https://sea.supercharged.ch/privacy with this content:

**Swiss Energy Assistant — Privacy Policy**

- No personal data is collected
- No registration required
- All user data (appliances, preferences) stored locally on device
- The app fetches publicly available electricity prices from CKW, Groupe E, and Primeo APIs
- No tracking, no analytics, no advertising
- Contact: [your email]

## 9. Review & Launch

### Timeline
1. **Day 0 (today):** Upload AAB to Internal Testing
2. **Day 1–2:** Test via Play Store link on your phone
3. **Day 3:** Promote to Production
4. **Day 3–7:** Google review (typically 1–3 days for new apps)
5. **Day 7+:** App live on Play Store

### Post-Launch
- Monitor crash reports in Play Console → Android Vitals
- Respond to user reviews
- Update every 2–4 weeks with improvements

## 10. iOS App Store

### ⚠️ macOS Required
iOS builds require **Xcode on macOS**. This Linux machine cannot build .ipa files.

### What You Need
1. **Mac** (MacBook, iMac, or Mac Mini) with Xcode 15+
2. **Apple Developer Account** ($99/year) at https://developer.apple.com
3. Transfer the project to your Mac:
   ```bash
   # On your Mac:
   rsync -avz yourserver:/home/yomo/mub/projects/experiment/ems/mobile/ ~/sea-mobile/
   cd ~/sea-mobile
   flutter build ios --release
   ```

### iOS App Store Checklist
- Same store listing (translated)
- Same screenshots (but in iOS format)
- App Review takes 1–3 days
- Must include privacy nutrition labels

### Alternative: TestFlight
Once built on Mac, upload to TestFlight for beta testing before full release.

---

## Quick Command Reference

```bash
# Build release AAB for Play Store
cd /home/yomo/mub/projects/experiment/ems/mobile
flutter build appbundle --release

# Build release APK for direct install
flutter build apk --release

# Install on connected phone
./install.sh

# Take screenshots
adb exec-out screencap -p > screenshot.png
```
