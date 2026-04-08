-- ============================================================
-- Relsoft TeamFlow - Seed Data
-- Migration: 003_seed_data.sql
--
-- Creates demo departments, users, meetings, tasks, etc.
-- NOTE: In production, users are created via Supabase Auth.
-- This seed uses direct inserts for development/testing only.
-- ============================================================

-- ============================================================
-- DEPARTMENTS
-- ============================================================
INSERT INTO public.departments (id, name, description) VALUES
    ('d0000001-0000-0000-0000-000000000001', 'Engineering', 'Software development and technical operations'),
    ('d0000001-0000-0000-0000-000000000002', 'Design', 'UI/UX design and brand identity'),
    ('d0000001-0000-0000-0000-000000000003', 'Product', 'Product management and strategy'),
    ('d0000001-0000-0000-0000-000000000004', 'Operations', 'Business operations and administration');

-- ============================================================
-- DEMO PROFILES
-- Note: In production, profiles are auto-created via the
-- handle_new_user() trigger when users sign up through Auth.
-- For seeding, we insert directly into profiles.
-- You must also create matching auth.users entries in Supabase
-- Dashboard or via the Admin API.
-- ============================================================

-- The following UUIDs should match auth.users entries created
-- via Supabase Dashboard > Authentication > Users > Add User

-- Example profile inserts (uncomment and update IDs after creating auth users):
/*
INSERT INTO public.profiles (id, full_name, email, role, job_title) VALUES
    -- Super Admin
    ('a0000001-0000-0000-0000-000000000001', 'Ahmed Hassan', 'ahmed@relsoft.com', 'super_admin', 'CTO'),
    -- Admin
    ('a0000001-0000-0000-0000-000000000002', 'Sarah Osman', 'sarah@relsoft.com', 'admin', 'Engineering Manager'),
    -- Team Leads
    ('a0000001-0000-0000-0000-000000000003', 'Mohamed Ali', 'mohamed@relsoft.com', 'team_lead', 'Lead Developer'),
    ('a0000001-0000-0000-0000-000000000004', 'Fatima Yusuf', 'fatima@relsoft.com', 'team_lead', 'Design Lead'),
    -- Staff
    ('a0000001-0000-0000-0000-000000000005', 'Omar Ibrahim', 'omar@relsoft.com', 'staff', 'Senior Developer'),
    ('a0000001-0000-0000-0000-000000000006', 'Amina Khalil', 'amina@relsoft.com', 'staff', 'Frontend Developer'),
    ('a0000001-0000-0000-0000-000000000007', 'Yusuf Ahmed', 'yusuf@relsoft.com', 'staff', 'UI Designer'),
    ('a0000001-0000-0000-0000-000000000008', 'Halima Abdi', 'halima@relsoft.com', 'staff', 'Product Analyst');
*/

-- ============================================================
-- TEAM MEMBERSHIPS (uncomment after creating profiles)
-- ============================================================
/*
INSERT INTO public.team_memberships (user_id, department_id, role_in_team) VALUES
    -- Engineering team
    ('a0000001-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000001', 'lead'),
    ('a0000001-0000-0000-0000-000000000003', 'd0000001-0000-0000-0000-000000000001', 'lead'),
    ('a0000001-0000-0000-0000-000000000005', 'd0000001-0000-0000-0000-000000000001', 'member'),
    ('a0000001-0000-0000-0000-000000000006', 'd0000001-0000-0000-0000-000000000001', 'member'),
    -- Design team
    ('a0000001-0000-0000-0000-000000000004', 'd0000001-0000-0000-0000-000000000002', 'lead'),
    ('a0000001-0000-0000-0000-000000000007', 'd0000001-0000-0000-0000-000000000002', 'member'),
    -- Product team
    ('a0000001-0000-0000-0000-000000000008', 'd0000001-0000-0000-0000-000000000003', 'member');
*/

-- ============================================================
-- SAMPLE MEETINGS (uncomment after creating profiles)
-- ============================================================
/*
INSERT INTO public.meetings (id, title, description, scheduled_at, department_id, organizer_id, created_by, status, agenda) VALUES
    (
        'm0000001-0000-0000-0000-000000000001',
        'Sprint Planning - Q2 Week 1',
        'Planning session for the upcoming sprint cycle',
        now() + interval '2 days',
        'd0000001-0000-0000-0000-000000000001',
        'a0000001-0000-0000-0000-000000000003',
        'a0000001-0000-0000-0000-000000000003',
        'scheduled',
        '1. Review backlog items\n2. Estimate story points\n3. Assign tasks\n4. Identify blockers'
    ),
    (
        'm0000001-0000-0000-0000-000000000002',
        'Design Review - New Dashboard',
        'Review proposed dashboard designs with stakeholders',
        now() - interval '1 day',
        'd0000001-0000-0000-0000-000000000002',
        'a0000001-0000-0000-0000-000000000004',
        'a0000001-0000-0000-0000-000000000004',
        'completed',
        '1. Present wireframes\n2. Discuss color palette\n3. Review responsive layouts\n4. Agree on next steps'
    ),
    (
        'm0000001-0000-0000-0000-000000000003',
        'Weekly Engineering Standup',
        'Regular weekly sync for the engineering team',
        now() - interval '3 hours',
        'd0000001-0000-0000-0000-000000000001',
        'a0000001-0000-0000-0000-000000000002',
        'a0000001-0000-0000-0000-000000000002',
        'completed',
        '1. Progress updates\n2. Blockers\n3. Action items'
    );

-- Meeting attendees
INSERT INTO public.meeting_attendees (meeting_id, user_id, attended) VALUES
    ('m0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000003', false),
    ('m0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000005', false),
    ('m0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000006', false),
    ('m0000001-0000-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000004', true),
    ('m0000001-0000-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000007', true),
    ('m0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000002', true),
    ('m0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000003', true),
    ('m0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000005', true),
    ('m0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000006', true);

-- Meeting notes
INSERT INTO public.meeting_notes (meeting_id, content, author_id, order_index) VALUES
    ('m0000001-0000-0000-0000-000000000002', 'Discussed new dashboard layout - agreed on card-based design with dark theme', 'a0000001-0000-0000-0000-000000000004', 1),
    ('m0000001-0000-0000-0000-000000000002', 'Color palette needs to align with updated brand guidelines', 'a0000001-0000-0000-0000-000000000007', 2),
    ('m0000001-0000-0000-0000-000000000003', 'API refactoring is 80% complete, on track for Friday', 'a0000001-0000-0000-0000-000000000005', 1),
    ('m0000001-0000-0000-0000-000000000003', 'Testing pipeline needs optimization - builds taking too long', 'a0000001-0000-0000-0000-000000000006', 2);

-- Meeting decisions
INSERT INTO public.meeting_decisions (meeting_id, decision_text, decided_by) VALUES
    ('m0000001-0000-0000-0000-000000000002', 'Use dark theme as default with option to switch to light', 'a0000001-0000-0000-0000-000000000004'),
    ('m0000001-0000-0000-0000-000000000002', 'Implement card-based layout for all dashboard widgets', 'a0000001-0000-0000-0000-000000000004'),
    ('m0000001-0000-0000-0000-000000000003', 'Move CI pipeline to GitHub Actions for better performance', 'a0000001-0000-0000-0000-000000000002');

-- Meeting action items
INSERT INTO public.meeting_action_items (meeting_id, description, assigned_to, due_date) VALUES
    ('m0000001-0000-0000-0000-000000000002', 'Create high-fidelity mockups for dashboard cards', 'a0000001-0000-0000-0000-000000000007', now() + interval '5 days'),
    ('m0000001-0000-0000-0000-000000000002', 'Update brand color tokens in design system', 'a0000001-0000-0000-0000-000000000004', now() + interval '3 days'),
    ('m0000001-0000-0000-0000-000000000003', 'Complete API refactoring and open PR', 'a0000001-0000-0000-0000-000000000005', now() + interval '2 days'),
    ('m0000001-0000-0000-0000-000000000003', 'Research GitHub Actions migration steps', 'a0000001-0000-0000-0000-000000000006', now() + interval '4 days');
*/

-- ============================================================
-- SAMPLE TASKS (uncomment after creating profiles)
-- ============================================================
/*
INSERT INTO public.tasks (id, title, description, assigned_to, assigned_by, department_id, priority, status, due_date, created_by) VALUES
    (
        't0000001-0000-0000-0000-000000000001',
        'Implement user authentication flow',
        'Build complete login, signup, and password reset flows using Supabase Auth',
        'a0000001-0000-0000-0000-000000000005',
        'a0000001-0000-0000-0000-000000000003',
        'd0000001-0000-0000-0000-000000000001',
        'high',
        'in_progress',
        now() + interval '5 days',
        'a0000001-0000-0000-0000-000000000003'
    ),
    (
        't0000001-0000-0000-0000-000000000002',
        'Design task management screens',
        'Create wireframes and high-fidelity designs for task list, detail, and creation screens',
        'a0000001-0000-0000-0000-000000000007',
        'a0000001-0000-0000-0000-000000000004',
        'd0000001-0000-0000-0000-000000000002',
        'high',
        'pending',
        now() + interval '7 days',
        'a0000001-0000-0000-0000-000000000004'
    ),
    (
        't0000001-0000-0000-0000-000000000003',
        'Set up CI/CD pipeline',
        'Configure GitHub Actions for automated testing and deployment',
        'a0000001-0000-0000-0000-000000000006',
        'a0000001-0000-0000-0000-000000000002',
        'd0000001-0000-0000-0000-000000000001',
        'medium',
        'blocked',
        now() + interval '3 days',
        'a0000001-0000-0000-0000-000000000002'
    ),
    (
        't0000001-0000-0000-0000-000000000004',
        'Write API documentation',
        'Document all REST endpoints with request/response examples',
        'a0000001-0000-0000-0000-000000000005',
        'a0000001-0000-0000-0000-000000000003',
        'd0000001-0000-0000-0000-000000000001',
        'low',
        'pending',
        now() + interval '14 days',
        'a0000001-0000-0000-0000-000000000003'
    ),
    (
        't0000001-0000-0000-0000-000000000005',
        'Prepare product roadmap presentation',
        'Create slides for the Q2 roadmap review with stakeholders',
        'a0000001-0000-0000-0000-000000000008',
        'a0000001-0000-0000-0000-000000000002',
        'd0000001-0000-0000-0000-000000000003',
        'urgent',
        'in_progress',
        now() + interval '1 day',
        'a0000001-0000-0000-0000-000000000002'
    );

-- Update blocker reason for blocked task
UPDATE public.tasks
SET blocker_reason = 'Waiting for DevOps team to provision GitHub runners'
WHERE id = 't0000001-0000-0000-0000-000000000003';

-- Sample task comments
INSERT INTO public.task_comments (task_id, author_id, content) VALUES
    ('t0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000005', 'Started working on the login screen. Email/password flow is complete.'),
    ('t0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000003', 'Looks great! Please also add remember me functionality.'),
    ('t0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000006', 'Blocked on infra. Will escalate to DevOps lead.'),
    ('t0000001-0000-0000-0000-000000000005', 'a0000001-0000-0000-0000-000000000008', 'First draft of slides is ready. Need input on revenue projections.');

-- Sample task updates
INSERT INTO public.task_updates (task_id, updated_by, old_status, new_status, note) VALUES
    ('t0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000005', 'pending', 'in_progress', 'Beginning implementation'),
    ('t0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000006', 'pending', 'in_progress', 'Started setup'),
    ('t0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000006', 'in_progress', 'blocked', 'Waiting for GitHub runner provisioning'),
    ('t0000001-0000-0000-0000-000000000005', 'a0000001-0000-0000-0000-000000000008', 'pending', 'in_progress', 'Working on first draft');
*/
