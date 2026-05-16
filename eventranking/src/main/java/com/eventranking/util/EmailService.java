package com.eventranking.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

/**
 * Email notification service using JavaMail.
 *
 * Configure SMTP settings below (Gmail example shown).
 * For Gmail: enable "App Passwords" in your Google Account security settings,
 * then set SMTP_PASSWORD to the 16-character app password.
 */
public class EmailService {

    // ── SMTP Configuration — update these ──────────────────
    private static final String SMTP_HOST     = "smtp.gmail.com";
    private static final int    SMTP_PORT     = 587;
    private static final String SMTP_USERNAME = "your-email@gmail.com";   // ← change
    private static final String SMTP_PASSWORD = "your-app-password";      // ← change
    private static final String FROM_NAME     = "Smart Campus Notice Board";
    // ────────────────────────────────────────────────────────

    private static Session buildSession() {
        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            SMTP_HOST);
        props.put("mail.smtp.port",            String.valueOf(SMTP_PORT));
        props.put("mail.smtp.ssl.trust",       SMTP_HOST);

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
            }
        });
    }

    /**
     * Send a plain HTML email.
     *
     * @param toEmail   recipient address
     * @param subject   email subject
     * @param htmlBody  HTML content
     */
    /**
     * Check app.properties mail.enabled flag.
     * Returns false during development so emails don't fail the build.
     */
    private static boolean isEmailEnabled() {
        try (java.io.InputStream is = EmailService.class
                .getClassLoader().getResourceAsStream("app.properties")) {
            if (is == null) return false;
            java.util.Properties props = new java.util.Properties();
            props.load(is);
            return "true".equalsIgnoreCase(props.getProperty("mail.enabled", "false"));
        } catch (Exception e) {
            return false;
        }
    }

    public static void sendEmail(String toEmail, String subject, String htmlBody) {
        if (!isEmailEnabled()) {
            System.out.println("[EmailService] (disabled) Would send to " + toEmail + " — " + subject);
            return;
        }
        // Run in background thread — never block the HTTP request
        new Thread(() -> {
            try {
                Session session = buildSession();
                Message message = new MimeMessage(session);
                message.setFrom(new InternetAddress(SMTP_USERNAME, FROM_NAME));
                message.setRecipients(Message.RecipientType.TO,
                        InternetAddress.parse(toEmail));
                message.setSubject(subject);
                message.setContent(htmlBody, "text/html; charset=UTF-8");
                Transport.send(message);
                System.out.println("[EmailService] Sent to " + toEmail);
            } catch (Exception e) {
                // Log but don't crash the app if email fails
                System.err.println("[EmailService] Failed to send email to " + toEmail
                        + " — " + e.getMessage());
            }
        }).start();
    }

    // ── Pre-built email templates ────────────────────────────

    /** Sent to student when their submitted event is approved. */
    public static void sendEventApprovedEmail(String toEmail, String userName,
                                               String eventTitle, String appUrl) {
        String subject = "✅ Your event has been approved — " + eventTitle;
        String body = buildTemplate(
            "Event Approved! 🎉",
            "Hi " + userName + ",",
            "Great news! Your event submission has been reviewed and <strong>approved</strong>. "
                + "It is now live on the Smart Campus Notice Board.",
            "<strong>" + eventTitle + "</strong>",
            "View your event on the board and start sharing it with your classmates.",
            appUrl, "View Event on Board"
        );
        sendEmail(toEmail, subject, body);
    }

    /** Sent to student when their event is rejected. */
    public static void sendEventRejectedEmail(String toEmail, String userName,
                                               String eventTitle, String appUrl) {
        String subject = "❌ Event submission update — " + eventTitle;
        String body = buildTemplate(
            "Submission Update",
            "Hi " + userName + ",",
            "Thank you for submitting your event. Unfortunately, after review, "
                + "your submission was not approved at this time.",
            "<strong>" + eventTitle + "</strong>",
            "You are welcome to revise and resubmit your event. "
                + "Please ensure it meets the campus notice board guidelines.",
            appUrl + "/submit-event.jsp", "Submit a New Event"
        );
        sendEmail(toEmail, subject, body);
    }

    /** Welcome email sent to new users on registration. */
    public static void sendWelcomeEmail(String toEmail, String userName, String appUrl) {
        String subject = "Welcome to Smart Campus Notice Board 🎓";
        String body = buildTemplate(
            "Welcome Aboard! 🎓",
            "Hi " + userName + ",",
            "Your account has been created successfully. You can now browse ranked "
                + "campus events, vote for your favourites, bookmark events, "
                + "and even submit your own event proposals.",
            "Smart Campus Notice Board",
            "Discover events ranked by community votes, bookmarks, and views. "
                + "The most popular events always rise to the top.",
            appUrl, "Explore Events"
        );
        sendEmail(toEmail, subject, body);
    }

    /** Upcoming event reminder sent 24 hours before the event. */
    public static void sendEventReminderEmail(String toEmail, String userName,
                                               String eventTitle, String eventDate,
                                               String location, String appUrl) {
        String subject = "⏰ Reminder: " + eventTitle + " is tomorrow!";
        String body = buildTemplate(
            "Event Reminder ⏰",
            "Hi " + userName + ",",
            "This is a reminder that an event you bookmarked is happening <strong>tomorrow</strong>!",
            eventTitle + " — " + eventDate + " at " + location,
            "Don't miss out! Check the event details for the latest information.",
            appUrl, "View Event Details"
        );
        sendEmail(toEmail, subject, body);
    }

    // ── HTML template ────────────────────────────────────────

    private static String buildTemplate(String heading, String greeting,
                                         String mainText, String highlight,
                                         String subText, String ctaUrl, String ctaText) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
              <meta charset="UTF-8"/>
              <meta name="viewport" content="width=device-width,initial-scale=1"/>
            </head>
            <body style="margin:0;padding:0;background:#f0f4f8;font-family:Arial,sans-serif;">
              <table width="100%%" cellpadding="0" cellspacing="0" style="background:#f0f4f8;padding:32px 0;">
                <tr><td align="center">
                  <table width="560" cellpadding="0" cellspacing="0"
                         style="background:#ffffff;border-radius:12px;overflow:hidden;
                                box-shadow:0 4px 12px rgba(0,0,0,.08);">

                    <!-- Header -->
                    <tr>
                      <td style="background:linear-gradient(135deg,#1a56db,#1e3a8a);
                                 padding:28px 32px;text-align:center;">
                        <div style="font-size:1.4rem;font-weight:800;color:#fff;">
                          📋 Smart Campus Notice Board
                        </div>
                      </td>
                    </tr>

                    <!-- Body -->
                    <tr>
                      <td style="padding:32px;">
                        <h2 style="margin:0 0 8px;color:#0f172a;font-size:1.3rem;">%s</h2>
                        <p style="margin:0 0 16px;color:#475569;">%s</p>
                        <p style="margin:0 0 20px;color:#334155;line-height:1.7;">%s</p>

                        <!-- Highlight box -->
                        <div style="background:#e8f0fe;border-left:4px solid #1a56db;
                                    border-radius:6px;padding:14px 18px;margin-bottom:20px;">
                          <div style="font-weight:700;color:#1a56db;">%s</div>
                        </div>

                        <p style="margin:0 0 24px;color:#64748b;font-size:.9rem;line-height:1.6;">%s</p>

                        <!-- CTA button -->
                        <table cellpadding="0" cellspacing="0">
                          <tr>
                            <td style="border-radius:8px;background:#1a56db;">
                              <a href="%s"
                                 style="display:inline-block;padding:12px 28px;
                                        color:#ffffff;font-weight:700;font-size:.95rem;
                                        text-decoration:none;">
                                %s →
                              </a>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                      <td style="background:#f8fafc;padding:16px 32px;
                                 border-top:1px solid #e2e8f0;text-align:center;">
                        <p style="margin:0;color:#94a3b8;font-size:.78rem;">
                          © 2025 Smart Campus Notice Board ·
                          <a href="%s" style="color:#1a56db;">Unsubscribe</a>
                        </p>
                      </td>
                    </tr>

                  </table>
                </td></tr>
              </table>
            </body>
            </html>
            """.formatted(heading, greeting, mainText, highlight,
                          subText, ctaUrl, ctaText, ctaUrl);
    }
}

