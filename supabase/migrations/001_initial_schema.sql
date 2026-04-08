-- ============================================================
-- Relsoft TeamFlow - Initial Database Schema
-- Migration: 001_initial_schema.sql
-- 
-- This creates all core tables, indexes, constraints,
-- and triggers for the TeamFlow application.
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- HELPER FUNCTIONS (table-independent)
-- ============================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'role', 'staff')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- TABLE: departments
-- ============================================================
CREATE TABLE public.departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_departments_active ON public.departments(is_active) WHERE deleted_at IS NULL;

CREATE TRIGGER update_departments_updated_at
    BEFORE UPDATE ON public.departments
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- TABLE: profiles (extends auth.users)
-- ============================================================
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL DEFAULT 'staff'
        CHECK (role IN ('super_admin', 'admin', 'team_lead', 'staff')),
    avatar_url TEXT,
    phone TEXT,
    job_title TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_seen_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_profiles_active ON public.profiles(is_active);
CREATE INDEX idx_profiles_email ON public.profiles(email);

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger: auto-create profile on auth signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- TABLE: team_memberships
-- ============================================================
CREATE TABLE public.team_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    department_id UUID NOT NULL REFERENCES public.departments(id) ON DELETE CASCADE,
    role_in_team TEXT NOT NULL DEFAULT 'member'
        CHECK (role_in_team IN ('lead', 'member')),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, department_id)
);

CREATE INDEX idx_team_memberships_user ON public.team_memberships(user_id);
CREATE INDEX idx_team_memberships_dept ON public.team_memberships(department_id);

CREATE TRIGGER update_team_memberships_updated_at
    BEFORE UPDATE ON public.team_memberships
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- HELPER FUNCTIONS (table-dependent - must be after tables)
-- ============================================================

-- Cached role lookup for RLS policies (performance optimization)
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT AS $$
    SELECT role FROM public.profiles WHERE id = (SELECT auth.uid());
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Cached department IDs lookup for RLS policies
CREATE OR REPLACE FUNCTION public.get_my_department_ids()
RETURNS UUID[] AS $$
    SELECT COALESCE(
        array_agg(department_id),
        '{}'::UUID[]
    )
    FROM public.team_memberships
    WHERE user_id = (SELECT auth.uid());
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ============================================================
-- TABLE: meetings
-- ============================================================
CREATE TABLE public.meetings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    scheduled_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    location TEXT,
    meeting_type TEXT DEFAULT 'general'
        CHECK (meeting_type IN ('general', 'standup', 'sprint_review', 'retrospective', 'planning', 'one_on_one', 'workshop', 'other')),
    status TEXT NOT NULL DEFAULT 'scheduled'
        CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    department_id UUID REFERENCES public.departments(id),
    organizer_id UUID NOT NULL REFERENCES public.profiles(id),
    agenda TEXT,
    summary TEXT,
    created_by UUID NOT NULL REFERENCES public.profiles(id),
    updated_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_meetings_scheduled ON public.meetings(scheduled_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_meetings_organizer ON public.meetings(organizer_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_meetings_department ON public.meetings(department_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_meetings_status ON public.meetings(status) WHERE deleted_at IS NULL;

CREATE TRIGGER update_meetings_updated_at
    BEFORE UPDATE ON public.meetings
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- TABLE: meeting_attendees
-- ============================================================
CREATE TABLE public.meeting_attendees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meeting_id UUID NOT NULL REFERENCES public.meetings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    attended BOOLEAN DEFAULT false,
    rsvp_status TEXT DEFAULT 'pending'
        CHECK (rsvp_status IN ('pending', 'accepted', 'declined', 'tentative')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(meeting_id, user_id)
);

CREATE INDEX idx_meeting_attendees_meeting ON public.meeting_attendees(meeting_id);
CREATE INDEX idx_meeting_attendees_user ON public.meeting_attendees(user_id);

-- ============================================================
-- TABLE: meeting_notes
-- ============================================================
CREATE TABLE public.meeting_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meeting_id UUID NOT NULL REFERENCES public.meetings(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    author_id UUID NOT NULL REFERENCES public.profiles(id),
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_meeting_notes_meeting ON public.meeting_notes(meeting_id, order_index);

CREATE TRIGGER update_meeting_notes_updated_at
    BEFORE UPDATE ON public.meeting_notes
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- TABLE: meeting_decisions
-- ============================================================
CREATE TABLE public.meeting_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meeting_id UUID NOT NULL REFERENCES public.meetings(id) ON DELETE CASCADE,
    decision_text TEXT NOT NULL,
    decided_by UUID REFERENCES public.profiles(id),
    context TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_meeting_decisions_meeting ON public.meeting_decisions(meeting_id);

CREATE TRIGGER update_meeting_decisions_updated_at
    BEFORE UPDATE ON public.meeting_decisions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- TABLE: meeting_action_items
-- ============================================================
CREATE TABLE public.meeting_action_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meeting_id UUID NOT NULL REFERENCES public.meetings(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    assigned_to UUID REFERENCES public.profiles(id),
    due_date TIMESTAMPTZ,
    is_completed BOOLEAN NOT NULL DEFAULT false,
    completed_at TIMESTAMPTZ,
    converted_to_task_id UUID,  -- FK added after tasks table
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_meeting_action_items_meeting ON public.meeting_action_items(meeting_id);
CREATE INDEX idx_meeting_action_items_assigned ON public.meeting_action_items(assigned_to);

CREATE TRIGGER update_meeting_action_items_updated_at
    BEFORE UPDATE ON public.meeting_action_items
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- TABLE: tasks
-- ============================================================
CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    assigned_to UUID REFERENCES public.profiles(id),
    assigned_by UUID NOT NULL REFERENCES public.profiles(id),
    meeting_id UUID REFERENCES public.meetings(id),
    action_item_id UUID REFERENCES public.meeting_action_items(id),
    department_id UUID REFERENCES public.departments(id),
    priority TEXT NOT NULL DEFAULT 'medium'
        CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'in_progress', 'blocked', 'completed', 'cancelled')),
    due_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    blocker_reason TEXT,
    tags TEXT[] DEFAULT '{}',
    created_by UUID NOT NULL REFERENCES public.profiles(id),
    updated_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- Add FK from meeting_action_items to tasks
ALTER TABLE public.meeting_action_items
    ADD CONSTRAINT fk_action_item_task
    FOREIGN KEY (converted_to_task_id) REFERENCES public.tasks(id);

CREATE INDEX idx_tasks_assigned_to ON public.tasks(assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_assigned_by ON public.tasks(assigned_by) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_status ON public.tasks(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_priority ON public.tasks(priority) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_department ON public.tasks(department_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_due_date ON public.tasks(due_date) WHERE deleted_at IS NULL AND status NOT IN ('completed', 'cancelled');
CREATE INDEX idx_tasks_meeting ON public.tasks(meeting_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_created_at ON public.tasks(created_at DESC) WHERE deleted_at IS NULL;

CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON public.tasks
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- TABLE: task_comments
-- ============================================================
CREATE TABLE public.task_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES public.profiles(id),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_task_comments_task ON public.task_comments(task_id, created_at DESC);
CREATE INDEX idx_task_comments_author ON public.task_comments(author_id);

CREATE TRIGGER update_task_comments_updated_at
    BEFORE UPDATE ON public.task_comments
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- TABLE: task_updates (status change history)
-- ============================================================
CREATE TABLE public.task_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    updated_by UUID NOT NULL REFERENCES public.profiles(id),
    old_status TEXT,
    new_status TEXT NOT NULL
        CHECK (new_status IN ('pending', 'in_progress', 'blocked', 'completed', 'cancelled')),
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_task_updates_task ON public.task_updates(task_id, created_at DESC);

-- ============================================================
-- TABLE: notifications
-- ============================================================
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL
        CHECK (type IN (
            'task_assigned', 'task_due_soon', 'task_overdue',
            'task_completed', 'task_comment', 'task_status_changed',
            'meeting_invited', 'meeting_reminder', 'meeting_updated',
            'mention', 'system'
        )),
    title TEXT NOT NULL,
    body TEXT,
    related_entity_type TEXT
        CHECK (related_entity_type IN ('task', 'meeting', 'comment', 'user')),
    related_entity_id UUID,
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notifications_user ON public.notifications(user_id, is_read, created_at DESC);
CREATE INDEX idx_notifications_unread ON public.notifications(user_id, created_at DESC) WHERE is_read = false;

-- ============================================================
-- TABLE: audit_logs (IMMUTABLE)
-- ============================================================
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES public.profiles(id),
    action TEXT NOT NULL
        CHECK (action IN (
            'meeting.created', 'meeting.updated', 'meeting.deleted',
            'task.created', 'task.updated', 'task.deleted',
            'task.assigned', 'task.reassigned', 'task.status_changed',
            'task.comment_added',
            'user.created', 'user.updated', 'user.role_changed',
            'user.deactivated', 'user.activated',
            'department.created', 'department.updated',
            'login', 'logout'
        )),
    entity_type TEXT
        CHECK (entity_type IN ('meeting', 'task', 'user', 'department', 'comment', 'system')),
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    metadata JSONB,
    ip_address INET,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_logs_actor ON public.audit_logs(actor_id, created_at DESC);
CREATE INDEX idx_audit_logs_entity ON public.audit_logs(entity_type, entity_id, created_at DESC);
CREATE INDEX idx_audit_logs_action ON public.audit_logs(action, created_at DESC);
CREATE INDEX idx_audit_logs_created ON public.audit_logs(created_at DESC);

-- ============================================================
-- TABLE: file_attachments
-- ============================================================
CREATE TABLE public.file_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type TEXT NOT NULL
        CHECK (entity_type IN ('meeting', 'task', 'comment', 'profile')),
    entity_id UUID NOT NULL,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_size BIGINT,
    mime_type TEXT,
    uploaded_by UUID NOT NULL REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_file_attachments_entity ON public.file_attachments(entity_type, entity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_file_attachments_uploader ON public.file_attachments(uploaded_by) WHERE deleted_at IS NULL;

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'attachments',
    'attachments',
    false,
    10485760,  -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif',
          'application/pdf',
          'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'text/plain', 'text/csv']
) ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars',
    'avatars',
    true,
    2097152,  -- 2MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;
