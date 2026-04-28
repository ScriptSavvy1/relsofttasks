-- ============================================================
-- Relsoft TeamFlow - Dashboard RPC Functions
-- Migration: 004_dashboard_queries.sql
--
-- Provides a simple RPC function for dashboard stats.
-- Called via: supabase.rpc('get_dashboard_stats')
--
-- Uses auth.uid() internally to prevent IDOR — callers cannot
-- request another user's stats.
-- ============================================================

-- Drop old signature if it exists (parameter changed)
DROP FUNCTION IF EXISTS public.get_dashboard_stats(UUID);

-- Dashboard stats scoped to the calling user via auth.uid()
CREATE OR REPLACE FUNCTION public.get_dashboard_stats()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_uid  UUID := auth.uid();
    v_role TEXT;
    v_total_tasks BIGINT;
    v_overdue BIGINT;
    v_completed BIGINT;
    v_meetings BIGINT;
    v_staff BIGINT;
BEGIN
    -- Reject anonymous / service-role-less calls
    IF v_uid IS NULL THEN
        RETURN json_build_object(
            'total_active_tasks', 0,
            'overdue_tasks', 0,
            'completed_this_month', 0,
            'meetings_this_week', 0,
            'total_staff', 0
        );
    END IF;

    SELECT role INTO v_role
    FROM profiles
    WHERE id = v_uid;

    IF v_role IS NULL THEN
        RETURN json_build_object(
            'total_active_tasks', 0,
            'overdue_tasks', 0,
            'completed_this_month', 0,
            'meetings_this_week', 0,
            'total_staff', 0
        );
    END IF;

    -- Count active tasks
    IF v_role IN ('super_admin', 'admin') THEN
        SELECT count(*) INTO v_total_tasks
        FROM tasks
        WHERE status IN ('pending', 'in_progress', 'blocked')
        AND deleted_at IS NULL;
    ELSE
        SELECT count(*) INTO v_total_tasks
        FROM tasks
        WHERE assigned_to = v_uid
        AND status IN ('pending', 'in_progress', 'blocked')
        AND deleted_at IS NULL;
    END IF;

    -- Count overdue
    IF v_role IN ('super_admin', 'admin') THEN
        SELECT count(*) INTO v_overdue
        FROM tasks
        WHERE status IN ('pending', 'in_progress', 'blocked')
        AND due_date < now()
        AND deleted_at IS NULL;
    ELSE
        SELECT count(*) INTO v_overdue
        FROM tasks
        WHERE assigned_to = v_uid
        AND status IN ('pending', 'in_progress', 'blocked')
        AND due_date < now()
        AND deleted_at IS NULL;
    END IF;

    -- Count completed this month
    IF v_role IN ('super_admin', 'admin') THEN
        SELECT count(*) INTO v_completed
        FROM tasks
        WHERE status = 'completed'
        AND completed_at >= date_trunc('month', now())
        AND deleted_at IS NULL;
    ELSE
        SELECT count(*) INTO v_completed
        FROM tasks
        WHERE assigned_to = v_uid
        AND status = 'completed'
        AND completed_at >= date_trunc('month', now())
        AND deleted_at IS NULL;
    END IF;

    -- Count meetings this week
    IF v_role IN ('super_admin', 'admin') THEN
        SELECT count(*) INTO v_meetings
        FROM meetings
        WHERE scheduled_at >= date_trunc('week', now())
        AND scheduled_at < date_trunc('week', now()) + interval '7 days'
        AND deleted_at IS NULL;
    ELSE
        SELECT count(*) INTO v_meetings
        FROM meeting_attendees ma
        JOIN meetings m ON m.id = ma.meeting_id
        WHERE ma.user_id = v_uid
        AND m.scheduled_at >= date_trunc('week', now())
        AND m.scheduled_at < date_trunc('week', now()) + interval '7 days'
        AND m.deleted_at IS NULL;
    END IF;

    -- Total active staff (visible to all, low-sensitivity count)
    SELECT count(*) INTO v_staff
    FROM profiles
    WHERE is_active = true;

    RETURN json_build_object(
        'total_active_tasks', v_total_tasks,
        'overdue_tasks', v_overdue,
        'completed_this_month', v_completed,
        'meetings_this_week', v_meetings,
        'total_staff', v_staff
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_dashboard_stats() TO authenticated;
