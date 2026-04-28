# Relsoft TeamFlow

A secure, scalable internal team productivity app for recording meeting notes, extracting action items, assigning tasks, and tracking execution across the team.

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Mobile App | Flutter (iOS + Android) |
| State Management | Riverpod (AsyncNotifier) |
| Architecture | Feature-first Clean Architecture |
| Navigation | GoRouter |
| Backend/DB/Auth | Supabase (PostgreSQL) |
| Serverless Functions | Vercel (TypeScript) |
| Validation | Zod (server-side) |

## Project Structure

```
relsoft_teamflow/
├── lib/                          # Flutter app
│   ├── main.dart                 # Entry point
│   ├── app.dart                  # MaterialApp + Router
│   ├── core/                     # Shared infrastructure
│   │   ├── constants/            # App, route, Supabase constants
│   │   ├── enums/                # UserRole, TaskStatus, TaskPriority
│   │   ├── errors/               # Exception & Failure classes
│   │   ├── network/              # Supabase client providers
│   │   ├── routing/              # GoRouter configuration
│   │   ├── theme/                # Colors, typography, spacing, theme
│   │   ├── utils/                # Validators, formatters, debouncer
│   │   └── widgets/              # Shared reusable widgets
│   └── features/                 # Feature modules
│       ├── auth/                 # Login, forgot password, splash
│       ├── dashboard/            # Dashboard with stats & charts
│       ├── meetings/             # Meeting CRUD, detail, attendees
│       ├── tasks/                # Task CRUD, my tasks, team tasks
│       ├── notifications/        # In-app notifications
│       ├── users/                # Staff management, invite
│       ├── profile/              # User profile
│       └── settings/             # App settings
├── supabase/                     # Database migrations
│   └── migrations/
│       ├── 001_initial_schema.sql    # Tables, indexes, triggers
│       ├── 002_rls_policies.sql      # Row Level Security
│       ├── 003_seed_data.sql         # Demo data
│       ├── 004_dashboard_queries.sql # Dashboard metrics function
│       └── 005_create_users.sql      # Dev seed users (local only)
├── vercel/                       # Serverless functions
│   ├── api/
│   │   ├── auth/invite-user.ts       # Admin user invitation
│   │   ├── tasks/assign.ts           # Task assignment (validated)
│   │   ├── notifications/send.ts     # Notification dispatch
│   │   ├── ai/summarize.ts           # AI placeholder
│   │   └── cron/check-overdue.ts     # Daily overdue check
│   └── lib/
│       ├── supabase-admin.ts         # Service role client
│       ├── auth-middleware.ts        # JWT verification
│       └── validators.ts            # Zod schemas
├── pubspec.yaml
├── .env.example
└── README.md
```

## Setup Guide

### Prerequisites

- Flutter SDK 3.24+ ([install guide](https://docs.flutter.dev/get-started/install))
- Node.js 20+ (for Vercel functions)
- A Supabase account ([supabase.com](https://supabase.com))
- A Vercel account ([vercel.com](https://vercel.com))

### 1. Supabase Setup

1. Create a new Supabase project at [app.supabase.com](https://app.supabase.com)
2. Go to **SQL Editor** and run the migration files in order:
   ```
   001_initial_schema.sql    → Creates all tables, triggers, functions
   002_rls_policies.sql      → Enables Row Level Security
   003_seed_data.sql         → Seeds departments (uncomment profiles after creating users)
   004_dashboard_queries.sql → Creates dashboard metrics function
   005_create_users.sql      → (Optional, LOCAL DEV ONLY) Seeds dev users with random passwords
   ```
3. Go to **Authentication > Users** and create your first user (Super Admin)
4. In **SQL Editor**, update the profile role:
   ```sql
   UPDATE profiles SET role = 'super_admin' WHERE email = 'your@email.com';
   ```
5. Copy your project URL and anon key from **Settings > API**

### 2. Flutter App Setup

```bash
cd relsoft_teamflow

# Copy environment config
cp .env.example .env
# Edit .env with your Supabase URL and anon key

# Install dependencies
flutter pub get

# Generate freezed/json_serializable code (if using code gen)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run
```

### 3. Vercel Functions Setup

```bash
cd vercel

# Install dependencies
npm install

# Copy environment config
cp .env.example .env.local
# Edit .env.local with your Supabase service_role key

# Test locally
npx vercel dev

# Deploy
npx vercel --prod
```

### 4. Create Demo Users

After deploying, use the invite-user endpoint or Supabase Dashboard to create:

| Email | Role | Department |
|-------|------|------------|
| admin@relsoft.com | super_admin | All |
| sarah@relsoft.com | admin | Engineering |
| mohamed@relsoft.com | team_lead | Engineering |
| fatima@relsoft.com | team_lead | Design |
| omar@relsoft.com | staff | Engineering |
| amina@relsoft.com | staff | Engineering |

## Security Architecture

### Defense in Depth

```
┌─────────────────────────────────────────────────┐
│  Layer 1: Client-Side (Flutter)                 │
│  • Form validation                              │
│  • Role-based UI rendering                      │
│  • ⚠️ NOT trusted for security                  │
├─────────────────────────────────────────────────┤
│  Layer 2: Auth (Supabase Auth)                  │
│  • JWT verification on every request            │
│  • Secure session management                    │
├─────────────────────────────────────────────────┤
│  Layer 3: Database (PostgreSQL RLS)             │
│  • Row Level Security on ALL tables             │
│  • Deny by default, grant explicitly            │
│  • Primary security boundary                    │
├─────────────────────────────────────────────────┤
│  Layer 4: Server (Vercel Functions)             │
│  • Privileged operations only                   │
│  • service_role key (never client-exposed)      │
│  • Additional validation + permission checks    │
└─────────────────────────────────────────────────┘
```

### Key Security Rules

- ✅ `service_role` key is NEVER in client code
- ✅ RLS enabled on ALL tables
- ✅ Audit logs are immutable (no UPDATE/DELETE policies)
- ✅ Staff can only access their own assigned data
- ✅ Team leads scoped to their department
- ✅ Server-side validation on all sensitive operations
- ✅ Soft delete preserves business data
- ✅ Protected fields (role, created_by) cannot be changed by unauthorized users

## User Roles

| Role | Scope | Can Create Meetings | Can Assign Tasks | Can View All | Can Manage Users |
|------|-------|--------------------:|--:|--:|--:|
| Super Admin | Global | ✅ | ✅ | ✅ | ✅ |
| Admin | Global | ✅ | ✅ | ✅ | ✅ |
| Team Lead | Department | ✅ | ✅ (own dept) | ❌ | ❌ |
| Staff | Own tasks | ❌ | ❌ | ❌ | ❌ |

## App Screens

| Screen | Route | Roles |
|--------|-------|-------|
| Splash | `/` | All |
| Login | `/login` | All |
| Dashboard | `/dashboard` | All |
| Meetings List | `/meetings` | Admin, Team Lead, Staff* |
| Meeting Detail | `/meetings/:id` | Varies by attendance |
| Create Meeting | `/meetings/create` | Admin, Team Lead |
| My Tasks | `/my-tasks` | All |
| All Tasks | `/tasks` | Admin, Team Lead |
| Task Detail | `/tasks/:id` | Varies by assignment |
| Create Task | `/tasks/create` | Admin, Team Lead |
| Team Tasks | `/team-tasks` | Team Lead |
| Notifications | `/notifications` | All |
| Staff Management | `/users` | Admin |
| Profile | `/profile` | All |
| Settings | `/settings` | All |

## Future AI Features (Architecture Ready)

The following can be added via Vercel functions without major refactoring:

- **Meeting summarization** → `POST /api/ai/summarize`
- **Action item extraction** → `POST /api/ai/extract-actions`
- **Priority suggestions** → New endpoint
- **Weekly team summaries** → New cron job
- **Bottleneck detection** → New endpoint

## Deployment

### Flutter App
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release
```

### Vercel Functions
```bash
cd vercel
npx vercel --prod
```

### Environment Variables Checklist

**Flutter (.env)**:
- `SUPABASE_URL` — Your Supabase project URL
- `SUPABASE_ANON_KEY` — Public anon key (safe for client)
- `VERCEL_API_URL` — Your Vercel deployment URL

**Vercel (Dashboard > Settings > Environment Variables)**:
- `SUPABASE_URL` — Same Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY` — ⚠️ SECRET — Never expose to client
- `SUPABASE_ANON_KEY` — Public anon key
- `CRON_SECRET` — Auto-generated by Vercel for cron jobs

> **Note:** `SUPABASE_JWT_SECRET` is not needed by the current server code — the
> Vercel functions use `getUser(jwt)` via the service role client, which validates
> JWTs through the Supabase API. Only add it if you implement custom JWT
> verification outside of the Supabase SDK.

## License

Proprietary — © 2026 Relsoft. All rights reserved.
