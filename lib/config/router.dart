import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/patient_list_screen.dart';
import '../screens/admission/admission_wizard_screen.dart';
import '../screens/workup/workup_dashboard_screen.dart';
import '../screens/timeline/timeline_view_screen.dart';
import '../screens/discharge/discharge_checkpoint_screen.dart';
import '../screens/settings/templates_screen.dart';
import '../screens/settings/mjpjay_screen.dart';
import '../screens/settings/ai_config_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/tasks/my_tasks_screen.dart';
import '../screens/reminders/reminders_inbox_screen.dart';
import '../screens/guidelines/guideline_updates_screen.dart';
import '../screens/handoff/handoff_note_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const admission = '/admission';
  static const workup = '/workup/:admissionId';
  static const timeline = '/timeline/:admissionId';
  static const discharge = '/discharge/:admissionId';
  static const templates = '/settings/templates';
  static const mjpjay = '/settings/mjpjay';
  static const aiConfig = '/settings/ai';
  static const profile = '/settings/profile';
  static const myTasks = '/tasks';
  static const reminders = '/reminders';
  static const guidelines = '/guidelines';
  static const handoff = '/handoff/:admissionId';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const PatientListScreen(),
    ),
    GoRoute(
      path: AppRoutes.admission,
      builder: (context, state) => const AdmissionWizardScreen(),
    ),
    GoRoute(
      path: '/workup/:admissionId',
      builder: (context, state) => WorkupDashboardScreen(
        admissionId: state.pathParameters['admissionId']!,
      ),
    ),
    GoRoute(
      path: '/timeline/:admissionId',
      builder: (context, state) => TimelineViewScreen(
        admissionId: state.pathParameters['admissionId']!,
      ),
    ),
    GoRoute(
      path: '/discharge/:admissionId',
      builder: (context, state) => DischargeCheckpointScreen(
        admissionId: state.pathParameters['admissionId']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.templates,
      builder: (context, state) => const TemplatesScreen(),
    ),
    GoRoute(
      path: AppRoutes.mjpjay,
      builder: (context, state) => const MjpjayScreen(),
    ),
    GoRoute(
      path: AppRoutes.aiConfig,
      builder: (context, state) => const AiConfigScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.myTasks,
      builder: (context, state) => const MyTasksScreen(),
    ),
    GoRoute(
      path: AppRoutes.reminders,
      builder: (context, state) => const RemindersInboxScreen(),
    ),
    GoRoute(
      path: AppRoutes.guidelines,
      builder: (context, state) => const GuidelineUpdatesScreen(),
    ),
    GoRoute(
      path: '/handoff/:admissionId',
      builder: (context, state) => HandoffNoteScreen(
        admissionId: state.pathParameters['admissionId']!,
      ),
    ),
  ],
);
