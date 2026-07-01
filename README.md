# Raid Masters League

A premium, original kabaddi league fan-engagement & management platform.
Built with Flutter + Firebase, inspired by the *category* of pro-kabaddi
apps but with its own name, branding, colors, and code — no copied logos,
marks, or assets from any existing league.

## Status: architecture scaffold (step 1 of many)

This is a genuinely large product — 19 fan-facing modules, a full admin
dashboard, a real-time live-scoring system, and a dozen extra features
(fantasy, predictions, wallet, multi-language, etc). That's realistically
weeks of engineering work, not one code dump. So this repo is being built
**incrementally, module by module**, the way a real team would:

1. ✅ Architecture, folder structure, theming, constants, routing skeleton
2. ✅ Firestore schema (`/firebase/firestore_structure/schema.md`)
3. ✅ Reference vertical slice: **Teams** feature, top to bottom
   (entity → repository interface → Firestore model → repository impl →
   Riverpod providers) — this is the pattern every other module follows
4. ✅ Auth module (splash, onboarding, login, register, forgot password)
5. ✅ Home screen + widgets (live banner, upcoming, results, points table, top raiders/defenders/MVP, news, videos, trending)
6. ⬜ Live Match Center + real-time scoring stream
7. ⬜ Teams/Players screens (UI on top of the repository already built)
8. ⬜ Schedule / Standings / Statistics
9. ⬜ News / Videos / Notifications / Favorites / Search / Profile
10. ⬜ Admin dashboard + Live Scoring System UI
11. ⬜ Extra features (fantasy, predictions, polls, quizzes, wallet, etc.)
12. ⬜ Cloud Functions (standings recompute, FCM fan-out, wallet mutations)
13. ⬜ Firestore security rules
14. ⬜ Localization (en, ta, hi, kn, te, mr)

**Tell me which module to build next** and I'll generate it completely —
screens, widgets, providers, and data wiring — in the same reviewable
pattern as the Teams slice.

## Architecture

Clean Architecture, feature-first:
