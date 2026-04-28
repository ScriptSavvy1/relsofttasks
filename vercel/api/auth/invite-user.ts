import type { VercelRequest, VercelResponse } from '@vercel/node';
import { randomBytes } from 'crypto';
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
 * 6. Returns success — password is never exposed in the response
 *
 * Uses service_role key — privileged operation.
 */
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const user = await verifyAuth(req, res, ['super_admin', 'admin']);
  if (!user) return;

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

    // Prevent privilege escalation: admin cannot create another admin
    if (user.role === 'admin' && role === 'admin') {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'Admins cannot create other admins. Contact a super admin.',
      });
    }

    const tempPassword = generateTempPassword();

    const { data: authData, error: authError } =
      await supabase.auth.admin.createUser({
        email,
        password: tempPassword,
        email_confirm: true,
        user_metadata: {
          full_name,
          role,
        },
      });

    if (authError) {
      console.error('Failed to create auth user:', authError);
      return res.status(500).json({
        error: 'Failed to create user',
        message: 'Could not create the authentication record',
      });
    }

    const newUserId = authData.user.id;

    const { error: profileError } = await supabase
      .from('profiles')
      .update({ job_title: job_title || null })
      .eq('id', newUserId);

    if (profileError) {
      console.error('Failed to update profile:', profileError);
    }

    const { error: membershipError } = await supabase
      .from('team_memberships')
      .insert({
        user_id: newUserId,
        department_id,
        role_in_team: role === 'team_lead' ? 'lead' : 'member',
      });

    if (membershipError) {
      console.error('Failed to add team membership:', membershipError);
    }

    const { error: auditError } = await supabase.from('audit_logs').insert({
      actor_id: user.id,
      action: 'user.created',
      entity_type: 'user',
      entity_id: newUserId,
      new_values: { email, full_name, role, department_id },
    });

    if (auditError) {
      console.error('Failed to create audit log:', auditError);
    }

    // TODO: Send welcome email with temporary password via Resend / SendGrid.
    // The password is intentionally never returned in the HTTP response.

    return res.status(201).json({
      success: true,
      message: 'User invited successfully. Temporary password must be delivered via email.',
      data: {
        user_id: newUserId,
        email,
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
  const bytes = randomBytes(16);
  let password = '';
  for (let i = 0; i < 16; i++) {
    password += chars.charAt(bytes[i] % chars.length);
  }
  return password;
}
