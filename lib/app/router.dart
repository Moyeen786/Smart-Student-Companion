import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_analytics.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_announcements.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_campus_service.dart';
import 'package:smart_student_companion/features/admin/domain/models/campus_service_models.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_dashboard.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_library.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_profile.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_secondary.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_utilities.dart';
import 'package:smart_student_companion/features/admin/presentation/announcement_details_screen.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/features/admin/presentation/create_announcement_screen.dart';
import 'package:smart_student_companion/features/admin/presentation/user_management.dart';
import 'package:smart_student_companion/features/notifications/presentation/announcement_reader_screen.dart';
import 'package:smart_student_companion/features/auth/presentation/login_screen.dart';
import 'package:smart_student_companion/features/auth/presentation/account_created_screen.dart';
import 'package:smart_student_companion/features/auth/presentation/registration_screens.dart';
import 'package:smart_student_companion/features/auth/presentation/splash_screen.dart';
import 'package:smart_student_companion/features/auth/presentation/welcome_screen.dart';
import 'package:smart_student_companion/features/parent/presentation/child_attendance.dart';
import 'package:smart_student_companion/features/parent/presentation/child_performance.dart';
import 'package:smart_student_companion/features/parent/presentation/parent_dashboard.dart';
import 'package:smart_student_companion/features/parent/data/parent_demo_mode.dart';
import 'package:smart_student_companion/features/parent/presentation/parent_phone_verification_screen.dart';
import 'package:smart_student_companion/features/parent/presentation/parent_profile_screen.dart';
import 'package:smart_student_companion/features/parent/presentation/parent_role_verification_screen.dart';
import 'package:smart_student_companion/features/student/presentation/student_assignments.dart';
import 'package:smart_student_companion/features/student/presentation/student_attendance.dart';
import 'package:smart_student_companion/features/student/presentation/student_dashboard.dart';
import 'package:smart_student_companion/features/student/presentation/student_notes.dart';
import 'package:smart_student_companion/features/student/presentation/student_profile.dart';
import 'package:smart_student_companion/features/student/presentation/student_timetable.dart';
import 'package:smart_student_companion/features/teacher/presentation/teacher_assignments.dart';
import 'package:smart_student_companion/features/teacher/presentation/teacher_attendance.dart';
import 'package:smart_student_companion/features/teacher/presentation/teacher_dashboard.dart';
import 'package:smart_student_companion/features/teacher/presentation/teacher_leave_requests.dart';
import 'package:smart_student_companion/features/lost_found/presentation/lost_found_screen.dart';
import 'package:smart_student_companion/models/user_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final location = state.uri.path;
      final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
      final user = authState.valueOrNull?.user;

      if (location == '/' ||
          location == '/welcome' ||
          location == '/login' ||
          location == '/parent-login' ||
          location == '/register/select-role' ||
          location.startsWith('/register/') ||
          location == '/account-created' ||
          location == '/forgot-password') {
        return null;
      }

      if (!isAuthenticated) {
        return '/login';
      }

      if (user == null) {
        return '/login';
      }

      if (location == '/parent-demo') {
        if (!parentDemoModeEnabled || user.role != UserRole.student) {
          return switch (user.role) {
            UserRole.student => '/student',
            UserRole.faculty => '/faculty',
            UserRole.parent => '/parent',
            UserRole.admin => '/admin',
          };
        }
        return null;
      }

      final isStudentVerificationRoute =
          location == '/who-are-you' ||
          location == '/parent-verify-role' ||
          location == '/parent-phone-verify' ||
          location == '/parent-verify-otp';
      if (isStudentVerificationRoute && user.role != UserRole.student) {
        return switch (user.role) {
          UserRole.student => null,
          UserRole.faculty => '/faculty',
          UserRole.parent => '/parent',
          UserRole.admin => '/admin',
        };
      }

      if (location.startsWith('/student') && user.role != UserRole.student) {
        return '/login';
      }
      if (location.startsWith('/faculty') && user.role != UserRole.faculty) {
        return '/login';
      }
      if (location.startsWith('/parent') &&
          location != '/parent-phone-verify' &&
          location != '/parent-verify-otp' &&
          location != '/parent-verify-role' &&
          user.role != UserRole.parent) {
        return '/login';
      }
      if (location.startsWith('/admin') && user.role != UserRole.admin) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/parent-login',
        builder: (context, state) =>
            const ParentPhoneVerificationScreen(parentLoginOnly: true),
      ),
      GoRoute(
        path: '/who-are-you',
        builder: (context, state) => const ParentRoleVerificationScreen(),
      ),
      GoRoute(
        path: '/parent-verify-role',
        builder: (context, state) => const ParentRoleVerificationScreen(),
      ),
      GoRoute(
        path: '/parent-phone-verify',
        builder: (context, state) => const ParentPhoneVerificationScreen(),
      ),
      GoRoute(
        path: '/parent-verify-otp',
        builder: (context, state) => const ParentPhoneVerificationScreen(),
      ),
      GoRoute(
        path: '/register',
        redirect: (context, state) => '/register/select-role',
      ),
      GoRoute(
        path: '/register/select-role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/register/student',
        builder: (context, state) =>
            const RegistrationScreen(role: UserRole.student),
      ),
      GoRoute(
        path: '/register/faculty',
        builder: (context, state) =>
            const RegistrationScreen(role: UserRole.faculty),
      ),
      GoRoute(
        path: '/register/admin',
        builder: (context, state) =>
            const RegistrationScreen(role: UserRole.admin),
      ),
      GoRoute(
        path: '/register/parent',
        builder: (context, state) => const ParentRegistrationScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/account-created',
        builder: (context, state) => AccountCreatedScreen(
          role: state.extra is UserRole
              ? state.extra! as UserRole
              : UserRole.student,
        ),
      ),
      GoRoute(
        path: '/announcements/:id',
        builder: (context, state) =>
            AnnouncementReaderScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: '/student/profile',
        builder: (context, state) => const StudentProfile(),
      ),
      GoRoute(
        path: '/student/attendance',
        builder: (context, state) => const StudentAttendance(),
      ),
      GoRoute(
        path: '/student/timetable',
        builder: (context, state) => const StudentTimetable(),
      ),
      GoRoute(
        path: '/student/assignments',
        builder: (context, state) => const StudentAssignments(),
      ),
      GoRoute(
        path: '/student/notes',
        builder: (context, state) => const StudentNotes(),
      ),
      GoRoute(
        path: '/student/lost-found',
        builder: (context, state) => const LostFoundScreen(),
      ),
      GoRoute(
        path: '/faculty',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: '/faculty/attendance',
        builder: (context, state) => const TeacherAttendance(),
      ),
      GoRoute(
        path: '/faculty/assignments',
        builder: (context, state) => const TeacherAssignments(),
      ),
      GoRoute(
        path: '/faculty/leave-requests',
        builder: (context, state) => const TeacherLeaveRequests(),
      ),
      GoRoute(
        path: '/faculty/lost-found',
        builder: (context, state) => const LostFoundScreen(),
      ),
      GoRoute(
        path: '/parent-demo',
        builder: (context, state) => const ParentDashboard(demoMode: true),
      ),
      GoRoute(
        path: '/parent',
        builder: (context, state) => const ParentDashboard(),
      ),
      GoRoute(
        path: '/parent/attendance',
        builder: (context, state) => const ChildAttendance(),
      ),
      GoRoute(
        path: '/parent/performance',
        builder: (context, state) => const ChildPerformance(),
      ),
      GoRoute(
        path: '/parent/profile',
        builder: (context, state) => const ParentProfileScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagement(),
      ),
      GoRoute(
        path: '/admin/users/:id',
        builder: (context, state) => const AdminSecondaryScreen(
          title: 'User details',
          subtitle: 'Review account and academic information.',
          icon: Icons.person_outline,
        ),
      ),
      GoRoute(
        path: '/admin/announcements',
        builder: (context, state) => const AdminAnnouncements(),
      ),
      GoRoute(
        path: '/admin/announcements/create',
        builder: (context, state) => const CreateAnnouncementScreen(),
      ),
      GoRoute(
        path: '/admin/announcements/:id',
        builder: (context, state) =>
            AnnouncementDetailsScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/admin/announcements/:id/edit',
        builder: (context, state) => CreateAnnouncementScreen(
          initialAnnouncement: state.extra as Announcement?,
          announcementId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AdminAnalytics(),
      ),
      GoRoute(
        path: '/admin/utilities',
        builder: (context, state) => const AdminUtilities(),
      ),
      GoRoute(
        path: '/admin/utilities/library',
        builder: (context, state) => const AdminLibrary(),
      ),
      GoRoute(
        path: '/admin/utilities/placements',
        builder: (context, state) =>
            const AdminCampusService(kind: CampusServiceKind.placements),
      ),
      GoRoute(
        path: '/admin/utilities/events',
        builder: (context, state) =>
            const AdminCampusService(kind: CampusServiceKind.events),
      ),
      GoRoute(
        path: '/admin/utilities/lost-found',
        builder: (context, state) =>
            const AdminCampusService(kind: CampusServiceKind.lostFound),
      ),
      GoRoute(
        path: '/admin/profile',
        builder: (context, state) => const AdminProfile(),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page not found'))),
  );

  ref.listen(authStateProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});

class AppRouter {
  static bool canAccessRoute(UserRole role, String route) {
    if (route == '/parent-demo') {
      return parentDemoModeEnabled && role == UserRole.student;
    }
    if (route == '/register/parent') return role == UserRole.student;
    if (route == '/who-are-you' ||
        route == '/parent-verify-role' ||
        route == '/parent-phone-verify' ||
        route == '/parent-verify-otp') {
      return role == UserRole.student;
    }
    if (route.startsWith('/admin')) {
      return role == UserRole.admin;
    }
    if (route.startsWith('/student')) {
      return role == UserRole.student;
    }
    if (route.startsWith('/faculty')) {
      return role == UserRole.faculty;
    }
    if (route.startsWith('/parent')) {
      return role == UserRole.parent;
    }
    switch (route) {
      case '/student':
      case '/student/profile':
      case '/student/attendance':
      case '/student/timetable':
      case '/student/assignments':
      case '/student/notes':
        return role == UserRole.student;
      case '/faculty':
      case '/faculty/attendance':
      case '/faculty/assignments':
      case '/faculty/leave-requests':
        return role == UserRole.faculty;
      case '/parent':
      case '/parent/attendance':
      case '/parent/performance':
      case '/parent/profile':
        return role == UserRole.parent;
      default:
        return true;
    }
  }
}
