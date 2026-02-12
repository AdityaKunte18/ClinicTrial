# ClinicalPilot

Clinical workflow app for Internal Medicine doctors in Indian government and teaching hospitals. Provides syndrome-based workup templates, 5-day timeline tracking, discharge safety gates, and MJPJAY/PMJAY scheme integration.

## Prerequisites

- **Flutter 3.41+** — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart 3.11+** (included with Flutter)
- **Git**
- **Chrome** (for web builds) or an Android/iOS device/emulator

Optional:
- **Supabase CLI** — `npx supabase` or [install guide](https://supabase.com/docs/guides/cli)
- **Supabase project** — free at [supabase.com](https://supabase.com)

## Quick Start

```bash
# 1. Clone the repo
git clone <repo-url> && cd MobileApp

# 2. Create your .env file
cp .env.example .env

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run -d chrome
```

The app runs in **demo mode** without Supabase. To enable backend features, add your Supabase credentials to `.env`.

## Environment Setup

Create a `.env` file in the project root (it's gitignored):

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

To get these values:
1. Create a project at [supabase.com](https://supabase.com)
2. Go to **Settings > API**
3. Copy the **Project URL** and **anon/public** key

### Running Without Supabase

Leave `.env` with the default placeholder values. The app will skip Supabase initialization and run in offline/demo mode. You can navigate all screens.

## Database Setup (Supabase)

Once you have a Supabase project:

1. Open the **SQL Editor** in your Supabase dashboard
2. Paste and run `supabase/migrations/001_initial_schema.sql`
3. This creates all 13 tables, indexes, and Row Level Security policies

## Project Structure

```
lib/
  config/
    env.dart              # Environment variable access
    theme.dart            # Material 3 theme (medical blue/teal)
    router.dart           # go_router with 14 routes
  models/                 # 13 Dart model classes (plain, no codegen)
    models.dart           # Barrel file — exports all models
    user.dart             # AppUser (avoids Supabase User conflict)
    hospital.dart
    patient.dart
    admission.dart
    admission_syndrome.dart
    syndrome_protocol.dart
    doctor_template_override.dart
    workup_item.dart
    clinical_order.dart
    scheme_package.dart
    reminder.dart
    guideline_update.dart
    audit_log.dart
  providers/
    auth_provider.dart    # Riverpod auth state providers
  screens/                # 14 screens organized by feature
    auth/                 # Login/onboarding
    home/                 # Patient list (main dashboard)
    admission/            # Admission wizard
    workup/               # Workup dashboard (6-tab checklist)
    timeline/             # 5-day Gantt view
    discharge/            # Discharge checkpoint (hard-blocks)
    settings/             # Templates, MJPJAY, AI config, Profile
    tasks/                # Personal task list
    reminders/            # Reminders inbox
    guidelines/           # Guideline update review
    handoff/              # Shift handoff notes
  services/
    supabase_service.dart # Supabase client initialization + helpers
  utils/                  # (ready for utilities)
  widgets/                # (ready for shared widgets)
supabase/
  migrations/
    001_initial_schema.sql  # Full schema: 13 tables, RLS, indexes
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x |
| Routing | go_router |
| Backend | Supabase (PostgreSQL + Auth + Realtime) |
| Local DB | sqflite (offline-first) |
| Secure Storage | flutter_secure_storage |
| AI (optional) | Claude API (behind feature flag) |

## Available Commands

```bash
# Run on Chrome
flutter run -d chrome

# Run on connected device
flutter run

# Analyze code
dart analyze lib

# Build for web
flutter build web

# Run tests
flutter test
```

## Current Status

Scaffolding complete. All 14 screens are placeholder stubs with routing wired up. Models and database schema are defined. Next step is implementing actual screen UI, starting with login/auth.
