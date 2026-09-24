import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_analytics.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_announcements.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_dashboard.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_profile.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_secondary.dart';
import 'package:smart_student_companion/features/admin/presentation/admin_utilities.dart';
import 'package:smart_student_companion/features/admin/presentation/create_announcement_screen.dart';
import 'package:smart_student_companion/features/admin/presentation/user_management.dart';
import 'package:smart_student_companion/features/auth/presentation/login_screen.dart';
import 'package:smart_student_companion/features/auth/presentation/account_created_screen.dart';
import 'package:smart_student_companion/features/auth/presentation/registration_screens.dart';
import 'package:smart_student_companion/features/auth/presentation/splash_screen.dart';
import 'package:smart_student_companion/features/auth/presentation/welcome_screen.dart';
import 'package:smart_student_companion/features/parent/presentation/child_attendance.dart';
import 'package:smart_student_companion/features/parent/presentation/child_performance.dart';
import 'package:smart_student_companion/features/parent/presentation/parent_dashboard.dart';
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

      if (location.startsWith('/student') && user.role != UserRole.student) {
        return '/login';
      }
      if (location.startsWith('/faculty') && user.role != UserRole.faculty) {
        return '/login';
      }
      if (location.startsWith('/parent') && user.role != UserRole.parent) {
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
        path: '/admin/analytics',
        builder: (context, state) => const AdminAnalytics(),
      ),
      GoRoute(
        path: '/admin/utilities',
        builder: (context, state) => const AdminUtilities(),
      ),
      GoRoute(
        path: '/admin/utilities/library',
        builder: (context, state) => const AdminSecondaryScreen(
          title: 'Library',
          subtitle: 'Books, circulation and library notices.',
          icon: Icons.menu_book_outlined,
        ),
      ),
      GoRoute(
        path: '/admin/utilities/placements',
        builder: (context, state) => const AdminSecondaryScreen(
          title: 'Placements',
          subtitle: 'Companies, drives and student outcomes.',
          icon: Icons.work_outline_rounded,
        ),
      ),
      GoRoute(
        path: '/admin/utilities/events',
        builder: (context, state) => const AdminSecondaryScreen(
          title: 'Events',
          subtitle: 'Publish and manage campus events.',
          icon: Icons.event_outlined,
        ),
      ),
      GoRoute(
        path: '/admin/utilities/lost-found',
        builder: (context, state) => const AdminSecondaryScreen(
          title: 'Lost & Found',
          subtitle: 'Review and resolve reported items.',
          icon: Icons.inventory_2_outlined,
        ),
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
        return role == UserRole.parent;
      default:
        return true;
    }
  }
}
