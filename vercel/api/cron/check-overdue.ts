import type { VercelRequest, VercelResponse } from '@vercel/node';
import { createAdminClient } from '../../lib/supabase-admin';

/**
 * GET /api/cron/check-overdue
 *
 * Scheduled job (runs daily at 8 AM via vercel.json cron config).
 * Checks for tasks that are past their due date and:
 * 1. Sends overdue notifications to assignees
 * 2. Sends overdue notifications to admins/team leads
 * 3. Sends due-soon notifications (within 24 hours)
 *
 * Protected by Vercel's CRON_SECRET header.
 */
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  // Verify cron secret (Vercel automatically sends this for cron jobs)
  const cronSecret = req.headers['authorization'];
  if (cronSecret !== `Bearer ${process.env.CRON_SECRET}`) {
    // Allow manual trigger in development
    if (process.env.NODE_ENV === 'production') {
      return res.status(401).json({ error: 'Unauthorized' });
    }
  }

  const supabase = createAdminClient();
  const now = new Date().toISOString();
  const in24Hours = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();

  try {
    // ── Find Overdue Tasks ──────────────────────────────
    const { data: overdueTasks, error: overdueError } = await supabase
      .from('tasks')
      .select('id, title, assigned_to, assigned_by, department_id, due_date')
      .is('deleted_at', null)
      .in('status', ['pending', 'in_progress', 'blocked'])
      .lt('due_date', now)
      .not('assigned_to', 'is', null);

    if (overdueError) {
      console.error('Error fetching overdue tasks:', overdueError);
    }

    let overdueNotifications = 0;

    if (overdueTasks && overdueTasks.length > 0) {
      // Create notifications for each overdue task
      const notifications = overdueTasks.map((task) => ({
        user_id: task.assigned_to,
        type: 'task_overdue' as const,
        title: 'Task overdue',
        body: `"${task.title}" is past its due date`,
        related_entity_type: 'task' as const,
        related_entity_id: task.id,
      }));

      // Also notify the task assigner
      const assignerNotifications = overdueTasks
        .filter((t) => t.assigned_by !== t.assigned_to)
        .map((task) => ({
          user_id: task.assigned_by,
          type: 'task_overdue' as const,
          title: 'Assigned task overdue',
          body: `"${task.title}" assigned by you is overdue`,
          related_entity_type: 'task' as const,
          related_entity_id: task.id,
        }));

      const allNotifications = [...notifications, ...assignerNotifications];

      const { error: insertError } = await supabase
        .from('notifications')
        .insert(allNotifications);

      if (insertError) {
        console.error('Error inserting overdue notifications:', insertError);
      } else {
        overdueNotifications = allNotifications.length;
      }
    }

    // ── Find Due-Soon Tasks ─────────────────────────────
    const { data: dueSoonTasks, error: dueSoonError } = await supabase
      .from('tasks')
      .select('id, title, assigned_to, due_date')
      .is('deleted_at', null)
      .in('status', ['pending', 'in_progress'])
      .gte('due_date', now)
      .lte('due_date', in24Hours)
      .not('assigned_to', 'is', null);

    let dueSoonNotifications = 0;

    if (dueSoonTasks && dueSoonTasks.length > 0) {
      const notifications = dueSoonTasks.map((task) => ({
        user_id: task.assigned_to,
        type: 'task_due_soon' as const,
        title: 'Task due soon',
        body: `"${task.title}" is due within 24 hours`,
        related_entity_type: 'task' as const,
        related_entity_id: task.id,
      }));

      const { error: insertError } = await supabase
        .from('notifications')
        .insert(notifications);

      if (!insertError) {
        dueSoonNotifications = notifications.length;
      }
    }

    // ── Create audit log entry ──────────────────────────
    await supabase.from('audit_logs').insert({
      action: 'task.status_changed',
      entity_type: 'system',
      metadata: {
        type: 'cron_check_overdue',
        overdue_tasks_found: overdueTasks?.length ?? 0,
        due_soon_tasks_found: dueSoonTasks?.length ?? 0,
        notifications_sent: overdueNotifications + dueSoonNotifications,
      },
    });

    return res.status(200).json({
      success: true,
      overdue_tasks: overdueTasks?.length ?? 0,
      due_soon_tasks: dueSoonTasks?.length ?? 0,
      notifications_sent: overdueNotifications + dueSoonNotifications,
    });
  } catch (error) {
    console.error('Cron check-overdue error:', error);
    return res.status(500).json({
      error: 'Internal Server Error',
      message: 'Cron job failed',
    });
  }
}
