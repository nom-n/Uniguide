# API Overview

The current backend provides authentication and device-token APIs. Guide content and task progress are local in the Flutter app during this phase and should later be moved behind authenticated content/progress APIs.

## Auth

- `POST /auth/email-otp/send`: sends an email verification code.
- `POST /auth/verify-email`: verifies code and returns a registration ticket.
- `POST /auth/register`: creates an email/password account.
- `POST /auth/login`: returns access and refresh tokens.
- `POST /auth/refresh`: rotates/refreshes access credentials.
- `POST /auth/logout`: invalidates the current refresh session.
- `POST /auth/logout-all`: invalidates all user sessions.
- `POST /auth/forgot-password`: sends a reset token email.
- `POST /auth/reset-password`: resets password with a valid token.
- `POST /auth/google`: signs in or creates a user with Google ID token.
- `POST /auth/apple`: signs in or creates a user with Apple identity token.

## User

- `GET /me`: returns the authenticated user profile.

## Devices

- `POST /devices/fcm-token`: stores or updates a device FCM token for authenticated notification delivery.

## Future APIs

- `GET /guides`: versioned guide content with locale and city filters.
- `GET /guides/:id`: guide article details.
- `GET /places`: important places filtered by city and type.
- `GET /tasks`: recommended checklist for the current student state.
- `PATCH /tasks/:id`: sync task completion.
- `POST /assistant/ask`: retrieval-based AI answer over approved content.
- `POST /reminders`: create residence, registration, and document reminders.

Swagger is exposed at `/docs` when the backend is running.
