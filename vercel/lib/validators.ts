import { z } from 'zod';

/**
 * Shared validation schemas for serverless function inputs.
 * Uses Zod for type-safe runtime validation.
 */

export const inviteUserSchema = z.object({
  email: z.string().email('Invalid email address'),
  full_name: z.string().min(2, 'Name must be at least 2 characters').max(100),
  role: z.enum(['staff', 'team_lead', 'admin'], {
    errorMap: () => ({ message: 'Role must be staff, team_lead, or admin' }),
  }),
  department_id: z.string().uuid('Invalid department ID'),
  job_title: z.string().max(100).optional(),
});

export const assignTaskSchema = z.object({
  task_id: z.string().uuid('Invalid task ID'),
  assigned_to: z.string().uuid('Invalid user ID'),
  note: z.string().max(500).optional(),
});

export const sendNotificationSchema = z.object({
  user_id: z.string().uuid('Invalid user ID'),
  type: z.enum([
    'task_assigned', 'task_due_soon', 'task_overdue',
    'task_completed', 'task_comment', 'task_status_changed',
    'meeting_invited', 'meeting_reminder', 'meeting_updated',
    'mention', 'system',
  ]),
  title: z.string().min(1).max(200),
  body: z.string().max(500).optional(),
  related_entity_type: z.enum(['task', 'meeting', 'comment', 'user']).optional(),
  related_entity_id: z.string().uuid().optional(),
});

export type InviteUserInput = z.infer<typeof inviteUserSchema>;
export type AssignTaskInput = z.infer<typeof assignTaskSchema>;
export type SendNotificationInput = z.infer<typeof sendNotificationSchema>;
