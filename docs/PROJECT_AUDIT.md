# UniGuide Project Audit

Date: 2026-06-09

## Current State

- Flutter mobile app exists with onboarding, province selection, profile/auth screens, Firebase Messaging setup, and a NestJS authentication backend.
- Backend includes JWT sessions, refresh tokens, email verification, password reset, social auth hooks, TypeORM migrations, Swagger, CORS, Helmet, and rate limiting.
- Existing guide, task, map, search, assistant, notification-reminder, and student-life flows were incomplete or placeholder-level.

## Completed During This Pass

- Added a structured student guide content layer covering pre-arrival, after-arrival, banking, housing, university life, transport, student tips, and important places.
- Added responsive guide pages with category filtering and full-text local search.
- Added detail pages with steps, required documents, warnings, tags, and map launch support.
- Added persistent settlement task checklist with progress tracking and suggested next step.
- Added a local smart assistant that routes questions to the most relevant verified in-app guide content.
- Added Material 3 `NavigationBar` with Home, Tasks, Guides, Assistant, and Profile.
- Added dark-mode support with persisted theme preference.
- Reworked the home page into a product dashboard instead of static placeholder cards.

## Main Gaps Found

- Content was too thin for real student onboarding.
- Tasks and guides navigation used placeholder pages.
- No local search or content categorization existed.
- Dark mode was not implemented.
- Profile page contains some mojibake text in older comments/string lists and should be normalized fully.
- Notification system syncs FCM tokens but lacks an in-app reminder scheduler for residence, registration, and missing documents.
- Backend focuses on authentication only; no APIs exist for guide content, user progress sync, reminders, admin content management, or AI assistant orchestration.
- API base URL defaults to local emulator HTTP and must be overridden for production.
- No Flutter widget/e2e tests were present before this pass.

## Security Notes

- Backend correctly blocks weak JWT secrets in production, enables Helmet, uses validation whitelisting, and stores tokens/passwords hashed.
- Production deployments must set `DATABASE_URL`, strong JWT secrets, SMTP credentials, HTTPS, restricted CORS, and secure secret management.
- Firebase config files are present in the repository; Firebase API keys are not usually secrets by themselves, but project access rules must be locked down.
- The assistant is intentionally local and non-generative for now to avoid leaking student data to an external model without consent and policy controls.

## Architecture Recommendations

- Move guide content to a versioned backend CMS when content becomes operationally maintained.
- Add a domain/repository layer for guide content, tasks, reminders, and profile progress.
- Sync checklist progress across devices through authenticated APIs.
- Add role-based admin APIs for content editors.
- Add a privacy-aware AI gateway with retrieval over approved content, moderation, audit logs, and clear disclaimers.

## UX Recommendations

- Add onboarding question flow: city, university, arrival status, residence status, housing status.
- Use that profile to personalize the next-step card and reminders.
- Add offline-first caching for guides.
- Add in-app language switcher beyond first launch.
- Add accessible labels to all custom interactive cards and keep contrast checks in CI.
