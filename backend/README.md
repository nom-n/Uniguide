# UniGuide Backend (NestJS + PostgreSQL)

Manual authentication backend with:
- Access/Refresh JWT tokens
- Refresh token rotation with reuse detection
- Session revocation (`logout`, `logout-all`)
- Email verification OTP codes and password reset tokens stored as hashes
- Google and Apple identity-token sign in
- Login rate limiting plus temporary account lock after repeated failures
- Device token storage for FCM (`/devices/fcm-token`)
- Swagger docs at `/docs`

## 1) Setup

1. Install Node.js 20+
2. Copy env:
   - `cp .env.example .env`
3. Update `.env` values (secrets + DB connection + SMTP + OAuth client IDs)
4. Install deps:
   - `npm install`
5. Run migrations:
   - `npm run migration:run`
6. Start server:
   - `npm run start:dev`

## 2) Endpoints

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `POST /auth/logout-all`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `POST /auth/email-otp/send`
- `POST /auth/verify-email/send`
- `POST /auth/verify-email`
- `POST /auth/google`
- `POST /auth/apple`
- `GET /me`
- `POST /devices/fcm-token`

Email verification uses a 6-digit OTP sent through SMTP. In `development`, if
SMTP is not configured, the OTP is logged in the backend console and also
returned as `devEmailVerificationCode`. Password reset still returns
`devResetToken` only outside production so you can test without an email
provider. In `production`, configure SMTP and the API does not return dev codes.

Manual registration flow:
1. `POST /auth/email-otp/send` with `email`.
2. `POST /auth/verify-email` with `email` and `code`; save the returned
   `registrationTicket`.
3. `POST /auth/register` with email, first/last name, password, profile emoji,
   gender, birth year, and `registrationTicket`.

## 3) Flutter integration

The Flutter app uses:
- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `POST /auth/logout-all`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `POST /auth/email-otp/send`
- `POST /auth/verify-email/send`
- `POST /auth/verify-email`
- `POST /auth/google`
- `POST /auth/apple`
- `GET /me`
- `POST /devices/fcm-token`

Run Flutter with:
- `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000 --dart-define=GOOGLE_WEB_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com`

For Apple sign-in on Android/web, also pass:
- `--dart-define=APPLE_SERVICE_ID=com.uniguide.service --dart-define=APPLE_REDIRECT_URI=https://your-domain.com/auth/apple/callback`

## 4) Android Google sign-in checklist

`ApiException: 10` means Google OAuth is not configured for this Android app.

1. In Firebase Console, open project `uniguide-fe9a7`.
2. Android app package must be `com.uniguide.app`.
3. Add the debug certificate fingerprints:
   - SHA1: `D2:06:5D:02:DF:1F:69:0C:C1:D2:6D:AF:BB:30:FB:10:31:84:B5:AB`
   - SHA256: `CC:B7:97:9A:C0:A4:40:77:D2:B6:8C:F9:CD:A4:25:0A:E5:6E:15:38:8F:34:DB:10:38:6C:2F:78:36:2F:06:C6`
4. Enable Google provider in Firebase Authentication.
5. Download a fresh `google-services.json` and replace
   `android/app/google-services.json`.
6. Copy the Web client ID from Google Cloud OAuth clients and pass it as
   `GOOGLE_WEB_CLIENT_ID`.

For a real phone, `10.0.2.2` will not reach your computer. Use your computer IP,
for example `--dart-define=API_BASE_URL=http://192.168.1.20:3000`, and keep the
backend running on the same network.
