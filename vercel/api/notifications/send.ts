import type { VercelRequest, VercelResponse } from '@vercel/node';
import { verifyAuth } from '../../lib/auth-middleware';
import { createAdminClient } from '../../lib/supabase-admin';
import { sendNotificationSchema } from '../../lib/validators';

/**
 * POST /api/notifications/send
 *
 * Creates an in-app notification for a user.
 * This endpoint is designed to be extensible:
 * - Currently creates in-app notifications
 * - Can be extended to send email notifications (via Resend/SendGrid)
 * - Can be extended to send push notifications (via FCM/APNs)
 *
 * Only admins and the system (via service key) can send notifications
 * to other users.
 */
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const user = await verifyAuth(req, res);
  if (!user) return;

  const validation = sendNotificationSchema.safeParse(req.body);
  if (!validation.success) {
    return res.status(400).json({
      error: 'Validation failed',
      details: validation.error.flatten().fieldErrors,
    });
  }

  const input = validation.data;
  const supabase = createAdminClient();

  try {
    // Non-admins can only send notifications to themselves
    if (!['super_admin', 'admin'].includes(user.role)) {
      if (input.user_id !== user.id) {
        return res.status(403).json({
          error: 'Forbidden',
          message: 'You can only create notifications for yourself',
        });
      }
    }

    // Insert notification
    const { data: notification, error } = await supabase
      .from('notifications')
      .insert({
        user_id: input.user_id,
        type: input.type,
        title: input.title,
        body: input.body,
        related_entity_type: input.related_entity_type,
        related_entity_id: input.related_entity_id,
      })
      .select()
      .single();

    if (error) {
      console.error('Failed to create notification:', error);
      return res.status(500).json({
        error: 'Failed to create notification',
        message: error.message,
      });
    }

    // ── Future: Email notification ───────────────────────
    // if (shouldSendEmail(input.type)) {
    //   await sendEmail({
    //     to: recipientEmail,
    //     subject: input.title,
    //     body: input.body,
    //   });
    // }

    // ── Future: Push notification ────────────────────────
    // if (shouldSendPush(input.type)) {
    //   await sendPushNotification({
    //     token: recipientFcmToken,
    //     title: input.title,
    //     body: input.body,
    //   });
    // }

    return res.status(201).json({
      success: true,
      notification,
    });
  } catch (error) {
    console.error('Send notification error:', error);
    return res.status(500).json({
      error: 'Internal Server Error',
      message: 'An unexpected error occurred',
    });
  }
}
