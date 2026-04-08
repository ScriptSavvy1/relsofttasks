import type { VercelRequest, VercelResponse } from '@vercel/node';
import { verifyAuth } from '../../lib/auth-middleware';
import { createAdminClient } from '../../lib/supabase-admin';
import { assignTaskSchema } from '../../lib/validators';

/**
 * POST /api/tasks/assign
 *
 * Assigns or reassigns a task to a user.
 * Performs server-side validation of permissions.
 *
 * Only super_admin, admin, and team_lead can assign tasks.
 * Team leads can only assign within their department.
 */
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const user = await verifyAuth(req, res, ['super_admin', 'admin', 'team_lead']);
  if (!user) return;

  const validation = assignTaskSchema.safeParse(req.body);
  if (!validation.success) {
    return res.status(400).json({
      error: 'Validation failed',
      details: validation.error.flatten().fieldErrors,
    });
  }

  const { task_id, assigned_to, note } = validation.data;
  const supabase = createAdminClient();

  try {
    // Fetch the task
    const { data: task, error: taskError } = await supabase
      .from('tasks')
      .select('id, assigned_to, department_id, status, title')
      .eq('id', task_id)
      .is('deleted_at', null)
      .single();

    if (taskError || !task) {
      return res.status(404).json({ error: 'Task not found' });
    }

    // Team lead scope check
    if (user.role === 'team_lead') {
      const { data: membership } = await supabase
        .from('team_memberships')
        .select('department_id')
        .eq('user_id', user.id);

      const deptIds = (membership || []).map((m: any) => m.department_id);
      if (!deptIds.includes(task.department_id)) {
        return res.status(403).json({
          error: 'Forbidden',
          message: 'You can only assign tasks within your department',
        });
      }
    }

    // Verify assignee exists and is active
    const { data: assignee, error: assigneeError } = await supabase
      .from('profiles')
      .select('id, is_active, full_name')
      .eq('id', assigned_to)
      .single();

    if (assigneeError || !assignee) {
      return res.status(404).json({ error: 'Assignee not found' });
    }

    if (!assignee.is_active) {
      return res.status(400).json({
        error: 'Cannot assign to inactive user',
      });
    }

    const oldAssignee = task.assigned_to;

    // Update the task
    await supabase
      .from('tasks')
      .update({
        assigned_to,
        assigned_by: user.id,
        updated_by: user.id,
      })
      .eq('id', task_id);

    // Create audit log
    const action = oldAssignee ? 'task.reassigned' : 'task.assigned';
    await supabase.from('audit_logs').insert({
      actor_id: user.id,
      action,
      entity_type: 'task',
      entity_id: task_id,
      old_values: { assigned_to: oldAssignee },
      new_values: { assigned_to },
    });

    // Create notification for the assignee
    await supabase.from('notifications').insert({
      user_id: assigned_to,
      type: 'task_assigned',
      title: 'New task assigned',
      body: `You have been assigned "${task.title}"`,
      related_entity_type: 'task',
      related_entity_id: task_id,
    });

    return res.status(200).json({
      success: true,
      message: `Task assigned to ${assignee.full_name}`,
    });
  } catch (error) {
    console.error('Assign task error:', error);
    return res.status(500).json({
      error: 'Internal Server Error',
      message: 'An unexpected error occurred',
    });
  }
}
