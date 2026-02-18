import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/patient_list_screen.dart';
import '../screens/admission/admission_wizard_screen.dart';
import '../screens/workup/workup_dashboard_screen.dart';
import '../screens/timeline/timeline_view_screen.dart';
import '../screens/discharge/discharge_checkpoint_screen.dart';
import '../screens/settings/templates_screen.dart';
import '../screens/settings/syndrome_detail_screen.dart';
import '../screens/settings/mjpjay_screen.dart';
import '../screens/settings/ai_config_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/tasks/my_tasks_screen.dart';
import '../screens/reminders/reminders_inbox_screen.dart';
import '../screens/guidelines/guideline_updates_screen.dart';
import '../screens/handoff/handoff_note_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/';
  static const admission = '/admission';
  static const workup = '/workup/:admissionId';
  static const timeline = '/timeline/:admissionId';
  static const discharge = '/discharge/:admissionId';
  static const templates = '/settings/templates';
  static const syndromeDetail = '/settings/templates/:syndromeId';
  static const mjpjay = '/settings/mjpjay';
  static const aiConfig = '/settings/ai';
  static const profile = '/settings/profile';
  static const myTasks = '/tasks';
  static const reminders = '/reminders';
  static const guidelines = '/guidelines';
  static const handoff = '/handoff/:admissionId';
}

/// Router provider — rebuilds when auth state changes.
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authChangeNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      final isAuth = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      final isSignupRoute = state.matchedLocation == AppRoutes.signup;

      // Not authenticated → redirect to login (unless already on login/signup)
      if (!isAuth && !isLoginRoute && !isSignupRoute) {
        return AppRoutes.login;
      }

      // Authenticated → redirect away from login/signup to home
      if (isAuth && (isLoginRoute || isSignupRoute)) {
        return AppRoutes.home;
      }

      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
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
          initialTab: state.uri.queryParameters['tab'],
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
        path: '/settings/templates/:syndromeId',
        builder: (context, state) => SyndromeDetailScreen(
          syndromeId: state.pathParameters['syndromeId']!,
        ),
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
});
