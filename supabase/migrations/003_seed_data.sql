-- ============================================================
-- Relsoft TeamFlow - Seed Data
-- Migration: 003_seed_data.sql
--
-- Creates demo departments only.
-- Users are created via Supabase Auth (SQL or Dashboard).
-- ============================================================

-- ============================================================
-- DEPARTMENTS
-- ============================================================
INSERT INTO public.departments (id, name, description) VALUES
    ('d0000001-0000-0000-0000-000000000001', 'Engineering', 'Software development and technical operations'),
    ('d0000001-0000-0000-0000-000000000002', 'Design', 'UI/UX design and brand identity'),
    ('d0000001-0000-0000-0000-000000000003', 'Product', 'Product management and strategy'),
    ('d0000001-0000-0000-0000-000000000004', 'Operations', 'Business operations and administration')
ON CONFLICT (name) DO NOTHING;
