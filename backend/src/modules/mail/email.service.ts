import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';
import type SMTPTransport from 'nodemailer/lib/smtp-transport';

@Injectable()
export class EmailService {
  private transporter?: nodemailer.Transporter<SMTPTransport.SentMessageInfo>;

  constructor(private readonly configService: ConfigService) {}

  async sendVerificationCode(to: string, code: string): Promise<void> {
    const transporter = this.getTransporter();
    if (!transporter) {
      console.log(`Email verification OTP for ${to}: ${code}`);
      return;
    }

    await transporter.sendMail({
      from: this.configService.get<string>('mail.from'),
      to,
      subject: 'UniGuide email verification code',
      text: `Your UniGuide verification code is ${code}. It expires in 10 minutes.`,
      html: `
        <div style="font-family: Arial, sans-serif; line-height: 1.5;">
          <h2>UniGuide email verification</h2>
          <p>Your verification code is:</p>
          <p style="font-size: 28px; font-weight: 700; letter-spacing: 4px;">${code}</p>
          <p>This code expires in 10 minutes.</p>
        </div>
      `,
    });
  }

  private getTransporter():
    | nodemailer.Transporter<SMTPTransport.SentMessageInfo>
    | undefined {
    if (this.transporter) return this.transporter;

    const host = this.configService.get<string>('mail.host');
    const user = this.configService.get<string>('mail.user');
    const pass = this.configService.get<string>('mail.pass');
    if (!host || !user || !pass) return undefined;

    this.transporter = nodemailer.createTransport({
      host,
      port: this.configService.get<number>('mail.port') ?? 587,
      secure: this.configService.get<boolean>('mail.secure') ?? false,
      auth: { user, pass },
    });
    return this.transporter;
  }
}
