function parseCorsOrigin(value: string): string | string[] {
  if (value === '*') return value;
  return value
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
}

export default () => {
  const env = process.env.NODE_ENV ?? 'development';
  const accessSecret = process.env.JWT_ACCESS_SECRET ?? 'access_secret';
  const refreshSecret = process.env.JWT_REFRESH_SECRET ?? 'refresh_secret';
  const databaseUrl = process.env.DATABASE_URL ?? '';
  const smtpHost = process.env.SMTP_HOST ?? '';
  const smtpPort = Number(process.env.SMTP_PORT ?? 587);
  const smtpUser = process.env.SMTP_USER ?? '';
  const smtpPass = process.env.SMTP_PASS ?? '';

  if (env === 'production') {
    if (!databaseUrl) {
      throw new Error('DATABASE_URL is required in production.');
    }
    if (accessSecret === 'access_secret' || refreshSecret === 'refresh_secret') {
      throw new Error('Strong JWT secrets are required in production.');
    }
    if (!smtpHost || !smtpUser || !smtpPass) {
      throw new Error('SMTP settings are required in production.');
    }
  }

  return {
    app: {
      port: Number(process.env.PORT ?? 3000),
      corsOrigin: parseCorsOrigin(process.env.APP_CORS_ORIGIN ?? '*'),
      env,
    },
    auth: {
      accessSecret,
      refreshSecret,
      accessTtl: process.env.ACCESS_TOKEN_TTL ?? '15m',
      refreshTtlDays: Number(process.env.REFRESH_TOKEN_TTL_DAYS ?? 14),
    },
    database: {
      url: databaseUrl,
    },
    mail: {
      host: smtpHost,
      port: smtpPort,
      secure: process.env.SMTP_SECURE === 'true',
      user: smtpUser,
      pass: smtpPass,
      from: process.env.MAIL_FROM ?? 'UniGuide <no-reply@uniguide.local>',
    },
    oauth: {
      googleClientId: process.env.GOOGLE_CLIENT_ID ?? '',
      appleClientId: process.env.APPLE_CLIENT_ID ?? '',
    },
  };
};
