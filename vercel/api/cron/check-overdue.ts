import type { VercelRequest, VercelResponse } from '@vercel/node';
import { createAdminClient } from '../../lib/supabase-admin';

/**
 * GET /api/cron/check-overdue
 *
 * Scheduled job (runs daily at 8 AM via vercel.json cron config).
 * Checks for tasks that are past their due date and:
 * 1. Sends overdue notifications to assignees (idempotent per task per day)
 * 2. Sends overdue notifications to admins/team leads
 * 3. Sends due-soon notifications (within 24 hours)
 *
 * Protected by Vercel's CRON_SECRET header.
 */
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  const cronSecret = req.headers['authorization'];
  if (cronSecret !== `Bearer ${process.env.CRON_SECRET}`) {
    if (process.env.NODE_ENV === 'production') {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    console.warn('Cron auth skipped — non-production environment');
  }

  const supabase = createAdminClient();
  const now = new Date().toISOString();
  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);
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
      return res.status(500).json({
        error: 'Failed to fetch overdue tasks',
        message: overdueError.message,
      });
    }

    let overdueNotifications = 0;

    if (overdueTasks && overdueTasks.length > 0) {
      // Deduplicate: find tasks that already received an overdue notification today
      const overdueTaskIds = overdueTasks.map((t) => t.id);
      const { data: existingNotifs } = await supabase
        .from('notifications')
        .select('related_entity_id')
        .in('related_entity_id', overdueTaskIds)
        .eq('type', 'task_overdue')
        .gte('created_at', todayStart.toISOString());

      const alreadyNotified = new Set(
        (existingNotifs ?? []).map((n: { related_entity_id: string }) => n.related_entity_id)
      );

      const newOverdue = overdueTasks.filter((t) => !alreadyNotified.has(t.id));

      if (newOverdue.length > 0) {
        const notifications = newOverdue.map((task) => ({
          user_id: task.assigned_to,
          type: 'task_overdue' as const,
          title: 'Task overdue',
          body: `"${task.title}" is past its due date`,
          related_entity_type: 'task' as const,
          related_entity_id: task.id,
        }));

        const assignerNotifications = newOverdue
          .filter((t) => t.assigned_by && t.assigned_by !== t.assigned_to)
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

    if (dueSoonError) {
      console.error('Error fetching due-soon tasks:', dueSoonError);
    }

    let dueSoonNotifications = 0;

    if (dueSoonTasks && dueSoonTasks.length > 0) {
      const dueSoonIds = dueSoonTasks.map((t) => t.id);
      const { data: existingDueSoon } = await supabase
        .from('notifications')
        .select('related_entity_id')
        .in('related_entity_id', dueSoonIds)
        .eq('type', 'task_due_soon')
        .gte('created_at', todayStart.toISOString());

      const alreadyNotifiedSoon = new Set(
        (existingDueSoon ?? []).map((n: { related_entity_id: string }) => n.related_entity_id)
      );

      const newDueSoon = dueSoonTasks.filter((t) => !alreadyNotifiedSoon.has(t.id));

      if (newDueSoon.length > 0) {
        const notifications = newDueSoon.map((task) => ({
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
    }

    // ── Create audit log entry ──────────────────────────
    const { error: auditError } = await supabase.from('audit_logs').insert({
      action: 'cron.check_overdue',
      entity_type: 'system',
      new_values: {
        overdue_tasks_found: overdueTasks?.length ?? 0,
        due_soon_tasks_found: dueSoonTasks?.length ?? 0,
        notifications_sent: overdueNotifications + dueSoonNotifications,
      },
    });

    if (auditError) {
      console.error('Failed to create cron audit log:', auditError);
    }

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
