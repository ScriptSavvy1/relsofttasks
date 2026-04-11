-- ============================================================
-- Relsoft TeamFlow - Create Users
-- Migration: 005_create_users.sql
--
-- Creates 3 users via Supabase Auth:
--   1. Admin (super_admin) - admin@relsoft.so
--   2. Abdisalam (staff)   - abdisalam@relsoft.so
--   3. Abdirahman (staff)  - abdirahman@relsoft.so
--
-- IMPORTANT: Run this in the Supabase SQL Editor (Dashboard).
-- The handle_new_user trigger will auto-create profiles.
-- Default password for all: Relsoft@2026
-- ============================================================

-- ============================================================
-- 1. ADMIN USER (super_admin)
-- ============================================================
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    'a0000001-0000-0000-0000-000000000001',
    'authenticated',
    'authenticated',
    'admin@relsoft.so',
    crypt('Relsoft@2026', gen_salt('bf')),
    now(),
    jsonb_build_object('full_name', 'Admin', 'role', 'super_admin'),
    now(),
    now(),
    '',
    ''
) ON CONFLICT (id) DO NOTHING;

-- Create identity for Admin
INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    provider_id,
    last_sign_in_at,
    created_at,
    updated_at
) VALUES (
    'a0000001-0000-0000-0000-000000000001',
    'a0000001-0000-0000-0000-000000000001',
    jsonb_build_object('sub', 'a0000001-0000-0000-0000-000000000001', 'email', 'admin@relsoft.so'),
    'email',
    'a0000001-0000-0000-0000-000000000001',
    now(),
    now(),
    now()
) ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. ABDISALAM (staff)
-- ============================================================
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    'a0000001-0000-0000-0000-000000000002',
    'authenticated',
    'authenticated',
    'abdisalam@relsoft.so',
    crypt('Relsoft@2026', gen_salt('bf')),
    now(),
    jsonb_build_object('full_name', 'Abdisalam', 'role', 'staff'),
    now(),
    now(),
    '',
    ''
) ON CONFLICT (id) DO NOTHING;

-- Create identity for Abdisalam
INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    provider_id,
    last_sign_in_at,
    created_at,
    updated_at
) VALUES (
    'a0000001-0000-0000-0000-000000000002',
    'a0000001-0000-0000-0000-000000000002',
    jsonb_build_object('sub', 'a0000001-0000-0000-0000-000000000002', 'email', 'abdisalam@relsoft.so'),
    'email',
    'a0000001-0000-0000-0000-000000000002',
    now(),
    now(),
    now()
) ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. ABDIRAHMAN (staff)
-- ============================================================
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    'a0000001-0000-0000-0000-000000000003',
    'authenticated',
    'authenticated',
    'abdirahman@relsoft.so',
    crypt('Relsoft@2026', gen_salt('bf')),
    now(),
    jsonb_build_object('full_name', 'Abdirahman', 'role', 'staff'),
    now(),
    now(),
    '',
    ''
) ON CONFLICT (id) DO NOTHING;

-- Create identity for Abdirahman
INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    provider_id,
    last_sign_in_at,
    created_at,
    updated_at
) VALUES (
    'a0000001-0000-0000-0000-000000000003',
    'a0000001-0000-0000-0000-000000000003',
    jsonb_build_object('sub', 'a0000001-0000-0000-0000-000000000003', 'email', 'abdirahman@relsoft.so'),
    'email',
    'a0000001-0000-0000-0000-000000000003',
    now(),
    now(),
    now()
) ON CONFLICT DO NOTHING;

-- ============================================================
-- ASSIGN TEAM MEMBERSHIPS (Optional)
-- Add all users to Engineering department
-- ============================================================
INSERT INTO public.team_memberships (user_id, department_id, role_in_team) VALUES
    ('a0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'lead'),
    ('a0000001-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000001', 'member'),
    ('a0000001-0000-0000-0000-000000000003', 'd0000001-0000-0000-0000-000000000001', 'member')
ON CONFLICT (user_id, department_id) DO NOTHING;
