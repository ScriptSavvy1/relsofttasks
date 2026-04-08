import { createClient, SupabaseClient } from '@supabase/supabase-js';

/**
 * Creates a Supabase admin client using the service_role key.
 * This bypasses RLS — use ONLY in server-side functions.
 * NEVER expose this client or the service_role key to the client.
 */
export function createAdminClient(): SupabaseClient {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url || !key) {
    throw new Error(
      'Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables'
    );
  }

  return createClient(url, key, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

/**
 * Creates a Supabase client scoped to a specific user's JWT.
 * This respects RLS policies for the given user.
 */
export function createUserClient(jwt: string): SupabaseClient {
  const url = process.env.SUPABASE_URL;
  const anonKey = process.env.SUPABASE_ANON_KEY;

  if (!url || !anonKey) {
    throw new Error(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY environment variables'
    );
  }

  return createClient(url, anonKey, {
    global: {
      headers: {
        Authorization: `Bearer ${jwt}`,
      },
    },
  });
}
