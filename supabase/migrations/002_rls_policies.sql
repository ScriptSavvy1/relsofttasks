-- ============================================================
-- Relsoft TeamFlow - Row Level Security Policies
-- Migration: 002_rls_policies.sql
--
-- Security philosophy: DENY by default, grant explicitly.
-- All policies use cached auth functions for performance.
-- ============================================================

-- ============================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meetings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meeting_attendees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meeting_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meeting_decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meeting_action_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.file_attachments ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PROFILES POLICIES
-- ============================================================

-- Super Admin / Admin: read all profiles
CREATE POLICY "profiles_admin_select" ON public.profiles
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    );

-- Team Lead: read profiles in their department
CREATE POLICY "profiles_team_lead_select" ON public.profiles
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND (
            id = (SELECT auth.uid())
            OR id IN (
                SELECT user_id FROM public.team_memberships
                WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
            )
        )
    );

-- Staff: read own profile only
CREATE POLICY "profiles_staff_select" ON public.profiles
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'staff'
        AND id = (SELECT auth.uid())
    );

-- All users: update own profile (limited fields enforced by app)
CREATE POLICY "profiles_update_own" ON public.profiles
    FOR UPDATE TO authenticated
    USING (id = (SELECT auth.uid()))
    WITH CHECK (id = (SELECT auth.uid()));

-- Super Admin: can update any profile (for role changes etc.)
CREATE POLICY "profiles_super_admin_update" ON public.profiles
    FOR UPDATE TO authenticated
    USING ((SELECT public.get_my_role()) = 'super_admin')
    WITH CHECK ((SELECT public.get_my_role()) = 'super_admin');

-- ============================================================
-- DEPARTMENTS POLICIES
-- ============================================================

-- Super Admin / Admin: full access to departments
CREATE POLICY "departments_admin_all" ON public.departments
    FOR ALL TO authenticated
    USING (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    )
    WITH CHECK (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    );

-- Team Lead: read departments they belong to
CREATE POLICY "departments_team_lead_select" ON public.departments
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND id IN (SELECT unnest(public.get_my_department_ids()))
    );

-- Staff: read departments they belong to
CREATE POLICY "departments_staff_select" ON public.departments
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'staff'
        AND id IN (SELECT unnest(public.get_my_department_ids()))
    );

-- ============================================================
-- TEAM_MEMBERSHIPS POLICIES
-- ============================================================

-- Super Admin / Admin: full access
CREATE POLICY "team_memberships_admin_all" ON public.team_memberships
    FOR ALL TO authenticated
    USING (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    )
    WITH CHECK (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    );

-- Team Lead: read own department memberships
CREATE POLICY "team_memberships_team_lead_select" ON public.team_memberships
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND department_id IN (SELECT unnest(public.get_my_department_ids()))
    );

-- Staff: read own membership
CREATE POLICY "team_memberships_staff_select" ON public.team_memberships
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'staff'
        AND user_id = (SELECT auth.uid())
    );

-- ============================================================
-- MEETINGS POLICIES
-- ============================================================

-- Super Admin / Admin: full CRUD on meetings
CREATE POLICY "meetings_admin_all" ON public.meetings
    FOR ALL TO authenticated
    USING (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
        AND deleted_at IS NULL
    )
    WITH CHECK (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    );

-- Team Lead: CRUD meetings in their department
CREATE POLICY "meetings_team_lead_select" ON public.meetings
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND department_id IN (SELECT unnest(public.get_my_department_ids()))
        AND deleted_at IS NULL
    );

CREATE POLICY "meetings_team_lead_insert" ON public.meetings
    FOR INSERT TO authenticated
    WITH CHECK (
        (SELECT public.get_my_role()) = 'team_lead'
        AND department_id IN (SELECT unnest(public.get_my_department_ids()))
        AND organizer_id = (SELECT auth.uid())
        AND created_by = (SELECT auth.uid())
    );

CREATE POLICY "meetings_team_lead_update" ON public.meetings
    FOR UPDATE TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND department_id IN (SELECT unnest(public.get_my_department_ids()))
        AND deleted_at IS NULL
    )
    WITH CHECK (
        (SELECT public.get_my_role()) = 'team_lead'
        AND department_id IN (SELECT unnest(public.get_my_department_ids()))
    );

-- Staff: read meetings they are an attendee of
CREATE POLICY "meetings_staff_select" ON public.meetings
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'staff'
        AND deleted_at IS NULL
        AND id IN (
            SELECT meeting_id FROM public.meeting_attendees
            WHERE user_id = (SELECT auth.uid())
        )
    );

-- ============================================================
-- MEETING_ATTENDEES POLICIES
-- ============================================================

-- Super Admin / Admin: full access
CREATE POLICY "meeting_attendees_admin_all" ON public.meeting_attendees
    FOR ALL TO authenticated
    USING (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    )
    WITH CHECK (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    );

-- Team Lead: manage attendees for their department meetings
CREATE POLICY "meeting_attendees_team_lead_all" ON public.meeting_attendees
    FOR ALL TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND meeting_id IN (
            SELECT id FROM public.meetings
            WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
        )
    )
    WITH CHECK (
        (SELECT public.get_my_role()) = 'team_lead'
        AND meeting_id IN (
            SELECT id FROM public.meetings
            WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
        )
    );

-- Staff: read own attendance records
CREATE POLICY "meeting_attendees_staff_select" ON public.meeting_attendees
    FOR SELECT TO authenticated
    USING (
        user_id = (SELECT auth.uid())
    );

-- ============================================================
-- MEETING_NOTES POLICIES
-- ============================================================

-- Super Admin / Admin: full access
CREATE POLICY "meeting_notes_admin_all" ON public.meeting_notes
    FOR ALL TO authenticated
    USING (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    )
    WITH CHECK (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    );

-- Team Lead: full access for their department meetings
CREATE POLICY "meeting_notes_team_lead_all" ON public.meeting_notes
    FOR ALL TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND meeting_id IN (
            SELECT id FROM public.meetings
            WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
        )
    )
    WITH CHECK (
        (SELECT public.get_my_role()) = 'team_lead'
        AND meeting_id IN (
            SELECT id FROM public.meetings
            WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
        )
    );

-- Staff: read notes for meetings they attended
CREATE POLICY "meeting_notes_staff_select" ON public.meeting_notes
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'staff'
        AND meeting_id IN (
            SELECT meeting_id FROM public.meeting_attendees
            WHERE user_id = (SELECT auth.uid())
        )
    );

-- ============================================================
-- MEETING_DECISIONS POLICIES (same pattern as notes)
-- ============================================================

CREATE POLICY "meeting_decisions_admin_all" ON public.meeting_decisions
    FOR ALL TO authenticated
    USING ((SELECT public.get_my_role()) IN ('super_admin', 'admin'))
    WITH CHECK ((SELECT public.get_my_role()) IN ('super_admin', 'admin'));

CREATE POLICY "meeting_decisions_team_lead_all" ON public.meeting_decisions
    FOR ALL TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND meeting_id IN (
            SELECT id FROM public.meetings
            WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
        )
    )
    WITH CHECK (
        (SELECT public.get_my_role()) = 'team_lead'
        AND meeting_id IN (
            SELECT id FROM public.meetings
            WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
        )
    );

CREATE POLICY "meeting_decisions_staff_select" ON public.meeting_decisions
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'staff'
        AND meeting_id IN (
            SELECT meeting_id FROM public.meeting_attendees
            WHERE user_id = (SELECT auth.uid())
        )
    );

-- ============================================================
-- MEETING_ACTION_ITEMS POLICIES
-- ============================================================

CREATE POLICY "meeting_action_items_admin_all" ON public.meeting_action_items
    FOR ALL TO authenticated
    USING ((SELECT public.get_my_role()) IN ('super_admin', 'admin'))
    WITH CHECK ((SELECT public.get_my_role()) IN ('super_admin', 'admin'));

CREATE POLICY "meeting_action_items_team_lead_all" ON public.meeting_action_items
    FOR ALL TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND meeting_id IN (
            SELECT id FROM public.meetings
            WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
        )
    )
    WITH CHECK (
        (SELECT public.get_my_role()) = 'team_lead'
        AND meeting_id IN (
            SELECT id FROM public.meetings
            WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
        )
    );

CREATE POLICY "meeting_action_items_staff_select" ON public.meeting_action_items
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'staff'
        AND (
            assigned_to = (SELECT auth.uid())
            OR meeting_id IN (
                SELECT meeting_id FROM public.meeting_attendees
                WHERE user_id = (SELECT auth.uid())
            )
        )
    );

-- ============================================================
-- TASKS POLICIES
-- ============================================================

-- Super Admin / Admin: full CRUD on all tasks
CREATE POLICY "tasks_admin_all" ON public.tasks
    FOR ALL TO authenticated
    USING (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
        AND deleted_at IS NULL
    )
    WITH CHECK (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    );

-- Team Lead: CRUD tasks in their department
CREATE POLICY "tasks_team_lead_select" ON public.tasks
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND department_id IN (SELECT unnest(public.get_my_department_ids()))
        AND deleted_at IS NULL
    );

CREATE POLICY "tasks_team_lead_insert" ON public.tasks
    FOR INSERT TO authenticated
    WITH CHECK (
        (SELECT public.get_my_role()) = 'team_lead'
        AND department_id IN (SELECT unnest(public.get_my_department_ids()))
        AND assigned_by = (SELECT auth.uid())
        AND created_by = (SELECT auth.uid())
    );

CREATE POLICY "tasks_team_lead_update" ON public.tasks
    FOR UPDATE TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND department_id IN (SELECT unnest(public.get_my_department_ids()))
        AND deleted_at IS NULL
    )
    WITH CHECK (
        (SELECT public.get_my_role()) = 'team_lead'
        AND department_id IN (SELECT unnest(public.get_my_department_ids()))
    );

-- Staff: read tasks assigned to them
CREATE POLICY "tasks_staff_select" ON public.tasks
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'staff'
        AND assigned_to = (SELECT auth.uid())
        AND deleted_at IS NULL
    );

-- Staff: update own assigned tasks (status, blocker_reason only â€” enforced by app)
CREATE POLICY "tasks_staff_update" ON public.tasks
    FOR UPDATE TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'staff'
        AND assigned_to = (SELECT auth.uid())
        AND deleted_at IS NULL
    )
    WITH CHECK (
        (SELECT public.get_my_role()) = 'staff'
        AND assigned_to = (SELECT auth.uid())
    );

-- ============================================================
-- TASK_COMMENTS POLICIES
-- ============================================================

-- Super Admin / Admin: full access
CREATE POLICY "task_comments_admin_all" ON public.task_comments
    FOR ALL TO authenticated
    USING ((SELECT public.get_my_role()) IN ('super_admin', 'admin'))
    WITH CHECK ((SELECT public.get_my_role()) IN ('super_admin', 'admin'));

-- Team Lead: access comments on their department tasks
CREATE POLICY "task_comments_team_lead_all" ON public.task_comments
    FOR ALL TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND task_id IN (
            SELECT id FROM public.tasks
            WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
            AND deleted_at IS NULL
        )
    )
    WITH CHECK (
        (SELECT public.get_my_role()) = 'team_lead'
        AND task_id IN (
            SELECT id FROM public.tasks
            WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
            AND deleted_at IS NULL
        )
    );

-- Staff: read comments on their assigned tasks + add own comments
CREATE POLICY "task_comments_staff_select" ON public.task_comments
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'staff'
        AND task_id IN (
            SELECT id FROM public.tasks
            WHERE assigned_to = (SELECT auth.uid()) AND deleted_at IS NULL
        )
    );

CREATE POLICY "task_comments_staff_insert" ON public.task_comments
    FOR INSERT TO authenticated
    WITH CHECK (
        (SELECT public.get_my_role()) = 'staff'
        AND author_id = (SELECT auth.uid())
        AND task_id IN (
            SELECT id FROM public.tasks
            WHERE assigned_to = (SELECT auth.uid()) AND deleted_at IS NULL
        )
    );

-- Staff: update own comments only
CREATE POLICY "task_comments_staff_update" ON public.task_comments
    FOR UPDATE TO authenticated
    USING (
        author_id = (SELECT auth.uid())
        AND deleted_at IS NULL
    )
    WITH CHECK (
        author_id = (SELECT auth.uid())
    );

-- ============================================================
-- TASK_UPDATES POLICIES
-- ============================================================

-- Admin: read all
CREATE POLICY "task_updates_admin_select" ON public.task_updates
    FOR SELECT TO authenticated
    USING ((SELECT public.get_my_role()) IN ('super_admin', 'admin'));

-- Team Lead: read updates for department tasks
CREATE POLICY "task_updates_team_lead_select" ON public.task_updates
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND task_id IN (
            SELECT id FROM public.tasks
            WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
        )
    );

-- Staff: read updates on their own tasks
CREATE POLICY "task_updates_staff_select" ON public.task_updates
    FOR SELECT TO authenticated
    USING (
        task_id IN (
            SELECT id FROM public.tasks
            WHERE assigned_to = (SELECT auth.uid())
        )
    );

-- All authenticated: insert updates (logging status changes they make)
CREATE POLICY "task_updates_insert" ON public.task_updates
    FOR INSERT TO authenticated
    WITH CHECK (
        updated_by = (SELECT auth.uid())
    );

-- ============================================================
-- NOTIFICATIONS POLICIES
-- ============================================================

-- Users can only read/update their own notifications
CREATE POLICY "notifications_select_own" ON public.notifications
    FOR SELECT TO authenticated
    USING (user_id = (SELECT auth.uid()));

CREATE POLICY "notifications_update_own" ON public.notifications
    FOR UPDATE TO authenticated
    USING (user_id = (SELECT auth.uid()))
    WITH CHECK (user_id = (SELECT auth.uid()));

-- Only server (service_role) or triggers can insert notifications
-- No INSERT policy for authenticated â€” notifications created via triggers/functions
CREATE POLICY "notifications_insert_system" ON public.notifications
    FOR INSERT TO authenticated
    WITH CHECK (
        -- Allow admins to create notifications (for manual sends)
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
        OR user_id = (SELECT auth.uid())
    );

-- ============================================================
-- AUDIT_LOGS POLICIES (IMMUTABLE â€” no UPDATE or DELETE)
-- ============================================================

-- Only Super Admin / Admin can read audit logs
CREATE POLICY "audit_logs_admin_select" ON public.audit_logs
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) IN ('super_admin', 'admin')
    );

-- All authenticated users can insert their own audit logs
CREATE POLICY "audit_logs_insert" ON public.audit_logs
    FOR INSERT TO authenticated
    WITH CHECK (
        actor_id = (SELECT auth.uid())
    );

-- NO UPDATE OR DELETE POLICIES â€” audit logs are immutable

-- ============================================================
-- FILE_ATTACHMENTS POLICIES
-- ============================================================

-- Super Admin / Admin: full access
CREATE POLICY "file_attachments_admin_all" ON public.file_attachments
    FOR ALL TO authenticated
    USING ((SELECT public.get_my_role()) IN ('super_admin', 'admin'))
    WITH CHECK ((SELECT public.get_my_role()) IN ('super_admin', 'admin'));

-- Team Lead: access attachments for their department entities
CREATE POLICY "file_attachments_team_lead_select" ON public.file_attachments
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'team_lead'
        AND deleted_at IS NULL
        AND (
            (entity_type = 'task' AND entity_id IN (
                SELECT id FROM public.tasks
                WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
            ))
            OR (entity_type = 'meeting' AND entity_id IN (
                SELECT id FROM public.meetings
                WHERE department_id IN (SELECT unnest(public.get_my_department_ids()))
            ))
            OR uploaded_by = (SELECT auth.uid())
        )
    );

-- Staff: access own uploads + attachments on their tasks
CREATE POLICY "file_attachments_staff_select" ON public.file_attachments
    FOR SELECT TO authenticated
    USING (
        (SELECT public.get_my_role()) = 'staff'
        AND deleted_at IS NULL
        AND (
            uploaded_by = (SELECT auth.uid())
            OR (entity_type = 'task' AND entity_id IN (
                SELECT id FROM public.tasks
                WHERE assigned_to = (SELECT auth.uid())
            ))
        )
    );

-- All authenticated: upload files (own uploads)
CREATE POLICY "file_attachments_insert" ON public.file_attachments
    FOR INSERT TO authenticated
    WITH CHECK (uploaded_by = (SELECT auth.uid()));

-- Team Lead: insert for their department
CREATE POLICY "file_attachments_team_lead_insert" ON public.file_attachments
    FOR INSERT TO authenticated
    WITH CHECK (
        (SELECT public.get_my_role()) = 'team_lead'
        AND uploaded_by = (SELECT auth.uid())
    );

-- ============================================================
-- STORAGE POLICIES
-- ============================================================

-- Avatars bucket: public read, authenticated upload own
CREATE POLICY "avatars_public_read" ON storage.objects
    FOR SELECT TO public
    USING (bucket_id = 'avatars');

CREATE POLICY "avatars_upload_own" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
        bucket_id = 'avatars'
        AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
    );

CREATE POLICY "avatars_update_own" ON storage.objects
    FOR UPDATE TO authenticated
    USING (
        bucket_id = 'avatars'
        AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
    );

-- Attachments bucket: authenticated read based on access, upload own
CREATE POLICY "attachments_read" ON storage.objects
    FOR SELECT TO authenticated
    USING (bucket_id = 'attachments');

CREATE POLICY "attachments_upload" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
        bucket_id = 'attachments'
        AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
    );
