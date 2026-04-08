import type { VercelRequest, VercelResponse } from '@vercel/node';
import { createAdminClient } from './supabase-admin';

interface AuthUser {
  id: string;
  email: string;
  role: string;
}

/**
 * Middleware to verify the JWT token from the Authorization header
 * and extract the user's role from the profiles table.
 *
 * Returns the authenticated user or sends a 401/403 response.
 */
export async function verifyAuth(
  req: VercelRequest,
  res: VercelResponse,
  requiredRoles?: string[]
): Promise<AuthUser | null> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({
      error: 'Unauthorized',
      message: 'Missing or invalid Authorization header',
    });
    return null;
  }

  const jwt = authHeader.replace('Bearer ', '');
  const supabase = createAdminClient();

  try {
    // Verify the JWT and get the user
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(jwt);

    if (authError || !user) {
      res.status(401).json({
        error: 'Unauthorized',
        message: 'Invalid or expired token',
      });
      return null;
    }

    // Fetch the user's profile to get their role
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('role, is_active')
      .eq('id', user.id)
      .single();

    if (profileError || !profile) {
      res.status(403).json({
        error: 'Forbidden',
        message: 'User profile not found',
      });
      return null;
    }

    // Check if user is active
    if (!profile.is_active) {
      res.status(403).json({
        error: 'Forbidden',
        message: 'Account is deactivated',
      });
      return null;
    }

    // Check required roles
    if (requiredRoles && requiredRoles.length > 0) {
      if (!requiredRoles.includes(profile.role)) {
        res.status(403).json({
          error: 'Forbidden',
          message: 'Insufficient permissions',
        });
        return null;
      }
    }

    return {
      id: user.id,
      email: user.email!,
      role: profile.role,
    };
  } catch (error) {
    console.error('Auth verification failed:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Authentication verification failed',
    });
    return null;
  }
}
