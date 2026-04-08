-- ============================================================
-- Relsoft TeamFlow - Dashboard Metrics Queries
-- 
-- Sample queries for dashboard statistics.
-- These can be used as PostgreSQL function  s or called
-- directly from the Flutter app via Supabase RPC.
-- ============================================================

-- ============================================================
-- FUNCTION: Get dashboard stats for a user based on their role
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_dashboard_stats(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_role TEXT;
    v_dept_ids UUID[];
    v_result JSON;
BEGIN
    -- Get user role
    SELECT role INTO v_role FROM public.profiles WHERE id = p_user_id;
    
    -- Get user department IDs
    SELECT COALESCE(array_agg(department_id), '{}')
    INTO v_dept_ids
    FROM public.team_memberships
    WHERE user_id = p_user_id;
    
    -- Build stats based on role
    IF v_role IN ('super_admin', 'admin') THEN
        -- Admins see everything
        SELECT json_build_object(
            'total_active_tasks', (
                SELECT count(*) FROM public.tasks
                WHERE status IN ('pending', 'in_progress', 'blocked')
                AND deleted_at IS NULL
            ),
            'overdue_tasks', (
                SELECT count(*) FROM public.tasks
                WHERE status IN ('pending', 'in_progress', 'blocked')
                AND due_date < now()
                AND deleted_at IS NULL
            ),
            'completed_this_month', (
                SELECT count(*) FROM public.tasks
                WHERE status = 'completed'
                AND completed_at >= date_trunc('month', now())
                AND deleted_at IS NULL
            ),
            'meetings_this_week', (
                SELECT count(*) FROM public.meetings
                WHERE scheduled_at >= date_trunc('week', now())
                AND scheduled_at < date_trunc('week', now()) + interval '7 days'
                AND deleted_at IS NULL
            ),
            'total_staff', (
                SELECT count(*) FROM public.profiles
                WHERE is_active = true
            ),
            'tasks_by_status', (
                SELECT json_object_agg(status, cnt)
                FROM (
                    SELECT status, count(*) as cnt
                    FROM public.tasks
                    WHERE deleted_at IS NULL
                    GROUP BY status
                ) sub
            ),
            'tasks_by_department', (
                SELECT json_object_agg(d.name, cnt)
                FROM (
                    SELECT department_id, count(*) as cnt
                    FROM public.tasks
                    WHERE deleted_at IS NULL
                    AND status IN ('pending', 'in_progress', 'blocked')
                    GROUP BY department_id
                ) sub
                JOIN public.departments d ON d.id = sub.department_id
            ),
            'recent_completions', (
                SELECT json_agg(json_build_object(
                    'task_id', t.id,
                    'title', t.title,
                    'completed_at', t.completed_at,
                    'assigned_to_name', p.full_name
                ))
                FROM (
                    SELECT id, title, completed_at, assigned_to
                    FROM public.tasks
                    WHERE status = 'completed'
                    AND deleted_at IS NULL
                    ORDER BY completed_at DESC
                    LIMIT 5
                ) t
                LEFT JOIN public.profiles p ON p.id = t.assigned_to
            )
        ) INTO v_result;
        
    ELSIF v_role = 'team_lead' THEN
        -- Team leads see their department
        SELECT json_build_object(
            'total_active_tasks', (
                SELECT count(*) FROM public.tasks
                WHERE department_id = ANY(v_dept_ids)
                AND status IN ('pending', 'in_progress', 'blocked')
                AND deleted_at IS NULL
            ),
            'overdue_tasks', (
                SELECT count(*) FROM public.tasks
                WHERE department_id = ANY(v_dept_ids)
                AND status IN ('pending', 'in_progress', 'blocked')
                AND due_date < now()
                AND deleted_at IS NULL
            ),
            'completed_this_month', (
                SELECT count(*) FROM public.tasks
                WHERE department_id = ANY(v_dept_ids)
                AND status = 'completed'
                AND completed_at >= date_trunc('month', now())
                AND deleted_at IS NULL
            ),
            'meetings_this_week', (
                SELECT count(*) FROM public.meetings
                WHERE department_id = ANY(v_dept_ids)
                AND scheduled_at >= date_trunc('week', now())
                AND scheduled_at < date_trunc('week', now()) + interval '7 days'
                AND deleted_at IS NULL
            ),
            'team_members', (
                SELECT count(*) FROM public.team_memberships
                WHERE department_id = ANY(v_dept_ids)
            ),
            'tasks_by_member', (
                SELECT json_agg(json_build_object(
                    'user_id', p.id,
                    'name', p.full_name,
                    'active_tasks', (
                        SELECT count(*) FROM public.tasks
                        WHERE assigned_to = p.id
                        AND status IN ('pending', 'in_progress', 'blocked')
                        AND deleted_at IS NULL
                    ),
                    'completed_tasks', (
                        SELECT count(*) FROM public.tasks
                        WHERE assigned_to = p.id
                        AND status = 'completed'
                        AND deleted_at IS NULL
                    )
                ))
                FROM public.profiles p
                WHERE p.id IN (
                    SELECT user_id FROM public.team_memberships
                    WHERE department_id = ANY(v_dept_ids)
                )
            )
        ) INTO v_result;
        
    ELSE
        -- Staff see only their own tasks
        SELECT json_build_object(
            'total_active_tasks', (
                SELECT count(*) FROM public.tasks
                WHERE assigned_to = p_user_id
                AND status IN ('pending', 'in_progress', 'blocked')
                AND deleted_at IS NULL
            ),
            'overdue_tasks', (
                SELECT count(*) FROM public.tasks
                WHERE assigned_to = p_user_id
                AND status IN ('pending', 'in_progress', 'blocked')
                AND due_date < now()
                AND deleted_at IS NULL
            ),
            'completed_this_month', (
                SELECT count(*) FROM public.tasks
                WHERE assigned_to = p_user_id
                AND status = 'completed'
                AND completed_at >= date_trunc('month', now())
                AND deleted_at IS NULL
            ),
            'upcoming_meetings', (
                SELECT count(*) FROM public.meeting_attendees ma
                JOIN public.meetings m ON m.id = ma.meeting_id
                WHERE ma.user_id = p_user_id
                AND m.scheduled_at >= now()
                AND m.deleted_at IS NULL
            )
        ) INTO v_result;
    END IF;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION public.get_dashboard_stats(UUID) TO authenticated;

-- ============================================================
-- STANDALONE DASHBOARD QUERIES (for reference)
-- ============================================================

-- Tasks by status breakdown
-- SELECT status, count(*) FROM tasks WHERE deleted_at IS NULL GROUP BY status;

-- Overdue tasks with assignee info
-- SELECT t.id, t.title, t.due_date, p.full_name as assigned_to
-- FROM tasks t
-- LEFT JOIN profiles p ON p.id = t.assigned_to
-- WHERE t.status IN ('pending', 'in_progress', 'blocked')
-- AND t.due_date < now()
-- AND t.deleted_at IS NULL
-- ORDER BY t.due_date ASC;

-- Team productivity: tasks completed per user this month
-- SELECT p.full_name, count(*) as completed_count
-- FROM tasks t
-- JOIN profiles p ON p.id = t.assigned_to
-- WHERE t.status = 'completed'
-- AND t.completed_at >= date_trunc('month', now())
-- AND t.deleted_at IS NULL
-- GROUP BY p.full_name
-- ORDER BY completed_count DESC;

-- Meeting frequency by department
-- SELECT d.name, count(*) as meeting_count
-- FROM meetings m
-- JOIN departments d ON d.id = m.department_id
-- WHERE m.scheduled_at >= date_trunc('month', now())
-- AND m.deleted_at IS NULL
-- GROUP BY d.name
-- ORDER BY meeting_count DESC;

-- Recent activity feed (last 20 events)
-- SELECT al.action, al.entity_type, al.created_at,
--        p.full_name as actor_name,
--        al.new_values
-- FROM audit_logs al
-- LEFT JOIN profiles p ON p.id = al.actor_id
-- ORDER BY al.created_at DESC
-- LIMIT 20;
