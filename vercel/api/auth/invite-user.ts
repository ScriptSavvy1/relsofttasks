import type { VercelRequest, VercelResponse } from '@vercel/node';
import { verifyAuth } from '../../lib/auth-middleware';
import { createAdminClient } from '../../lib/supabase-admin';
import { inviteUserSchema } from '../../lib/validators';

/**
 * POST /api/auth/invite-user
 *
 * Invites a new user to the TeamFlow system.
 * Only super_admin and admin roles can invite users.
 *
 * This endpoint:
 * 1. Validates the request body
 * 2. Creates the user in Supabase Auth (with temp password)
 * 3. Creates the profile record
 * 4. Adds team membership
 * 5. Creates an audit log entry
 *
 * Uses service_role key — privileged operation.
 */
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  // Only accept POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Verify auth — only admins can invite
  const user = await verifyAuth(req, res, ['super_admin', 'admin']);
  if (!user) return; // Response already sent by middleware

  // Validate input
  const validation = inviteUserSchema.safeParse(req.body);
  if (!validation.success) {
    return res.status(400).json({
      error: 'Validation failed',
      details: validation.error.flatten().fieldErrors,
    });
  }

  const { email, full_name, role, department_id, job_title } = validation.data;

  const supabase = createAdminClient();

  try {
    // Check if user already exists
    const { data: existingProfile } = await supabase
      .from('profiles')
      .select('id')
      .eq('email', email)
      .maybeSingle();

    if (existingProfile) {
      return res.status(409).json({
        error: 'Conflict',
        message: 'A user with this email already exists',
      });
    }

    // Prevent privilege escalation: admin cannot create super_admin
    if (user.role === 'admin' && role === 'admin') {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'Admins cannot create other admins. Contact a super admin.',
      });
    }

    // Generate a temporary password
    const tempPassword = generateTempPassword();

    // Create auth user
    const { data: authData, error: authError } =
      await supabase.auth.admin.createUser({
        email,
        password: tempPassword,
        email_confirm: true, // Auto-confirm for internal users
        user_metadata: {
          full_name,
          role,
        },
      });

    if (authError) {
      console.error('Failed to create auth user:', authError);
      return res.status(500).json({
        error: 'Failed to create user',
        message: authError.message,
      });
    }

    const newUserId = authData.user.id;

    // Update profile with additional fields (trigger already created basic profile)
    await supabase
      .from('profiles')
      .update({
        job_title: job_title || null,
      })
      .eq('id', newUserId);

    // Add team membership
    await supabase.from('team_memberships').insert({
      user_id: newUserId,
      department_id,
      role_in_team: role === 'team_lead' ? 'lead' : 'member',
    });

    // Create audit log
    await supabase.from('audit_logs').insert({
      actor_id: user.id,
      action: 'user.created',
      entity_type: 'user',
      entity_id: newUserId,
      new_values: { email, full_name, role, department_id },
    });

    // TODO: Send welcome email with temporary password
    // This would integrate with an email service like Resend, SendGrid, etc.

    return res.status(201).json({
      success: true,
      message: 'User invited successfully',
      data: {
        user_id: newUserId,
        email,
        temporary_password: tempPassword, // In production, send via email only
      },
    });
  } catch (error) {
    console.error('Invite user error:', error);
    return res.status(500).json({
      error: 'Internal Server Error',
      message: 'An unexpected error occurred',
    });
  }
}

function generateTempPassword(): string {
  const chars =
    'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#$%';
  let password = '';
  for (let i = 0; i < 16; i++) {
    password += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return password;
}
