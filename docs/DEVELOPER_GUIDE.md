# Developer Guide

## Project Layout

- `lib/core`: shared constants, auth, notifications, navigation, and guide content.
- `lib/features`: feature-first UI modules.
- `lib/l10n`: generated localization files and ARB sources.
- `backend/src`: NestJS modules, entities, migrations, configuration, and bootstrap.
- `docs`: audit, architecture, API, and operational documentation.

## Flutter Standards

- Keep UI feature code inside `lib/features/<feature>`.
- Keep reusable domain/content models inside `lib/core`.
- Prefer small widgets, immutable models, and local persistence only for non-sensitive preferences/progress.
- Store credentials and tokens only in `flutter_secure_storage`.
- Use `--dart-define=API_BASE_URL=...` for environment-specific API hosts.

## Backend Standards

- Keep controllers thin and place business logic in services.
- Validate DTOs with `class-validator`.
- Use TypeORM migrations; do not enable `synchronize` in production.
- Protect user APIs with JWT guards and apply throttling to public auth endpoints.
- Never commit production secrets.

## Testing

Run Flutter tests:

```bash
flutter test
```

Run backend tests:

```bash
cd backend
npm test
```

## Release Flow

1. Run formatters and tests.
2. Verify API URL and Firebase project.
3. Build signed Android/iOS artifacts.
4. Deploy backend with migrations.
5. Smoke-test auth, guides, search, tasks, assistant, and notifications.
