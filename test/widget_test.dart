import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:smart_student_companion/features/auth/presentation/registration_screens.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:smart_student_companion/features/student/presentation/student_profile.dart';
import 'package:smart_student_companion/features/parent/presentation/parent_dashboard.dart';
import 'package:smart_student_companion/features/parent/data/parent_providers.dart';
import 'package:smart_student_companion/features/parent/data/parent_demo_mode.dart';
import 'package:smart_student_companion/models/user_model.dart';

void main() {
  testWidgets('app loads the login portal', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('REGISTER NOW'), findsOneWidget);
  });

  testWidgets('Parent role card opens its student approval gate', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('REGISTER NOW'));
    await tester.tap(find.text('REGISTER NOW'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Parent').first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'A Student must sign in and approve access before a Parent link can be created.',
      ),
      findsOneWidget,
    );
    expect(find.text('Student Sign In'), findsOneWidget);
  });

  testWidgets(
    'parent sign-in entry opens phone verification without student login',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('PARENT SIGN IN WITH PHONE'));
      await tester.tap(find.text('PARENT SIGN IN WITH PHONE'));
      await tester.pumpAndSettle();

      expect(find.text('Parent Sign In'), findsOneWidget);
      expect(find.text('Registered Mobile Number'), findsOneWidget);
      expect(find.text('Roll No:'), findsNothing);
    },
  );

  testWidgets('parent dashboard does not render generated academic samples', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          parentChildProfileProvider.overrideWith(
            (ref) async => throw StateError(
              'This Parent account has no trusted child link.',
            ),
          ),
        ],
        child: const MaterialApp(home: ParentDashboard()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('This Parent account has no trusted child link.'),
      findsOneWidget,
    );
    expect(find.text('8.42'), findsNothing);
    expect(find.text('89.4%'), findsNothing);
  });

  testWidgets('demo dashboard renders only fictional sample records', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [parentDemoModeProvider.overrideWithValue(true)],
        child: const MaterialApp(home: ParentDashboard(demoMode: true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('DEMO MODE'), findsOneWidget);
    expect(find.text('Aarav Sample'), findsOneWidget);
    expect(find.byTooltip('Sign out'), findsNothing);
  });

  testWidgets('explicit demo mode simulates registration without SMS', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/register/parent',
      routes: [
        GoRoute(
          path: '/register/parent',
          builder: (_, _) => const ParentRegistrationScreen(),
        ),
        GoRoute(
          path: '/parent-demo',
          builder: (_, _) => const Scaffold(body: Text('Sample dashboard')),
        ),
        GoRoute(
          path: '/student',
          builder: (_, _) => const Scaffold(body: Text('Student dashboard')),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        parentDemoModeProvider.overrideWithValue(true),
      ],
    );
    await container
        .read(authStateProvider.notifier)
        .login('student@example.edu', 'password');
    container
        .read(authStateProvider.notifier)
        .setAuthenticatedUser(
          UserModel(
            uid: 'student-real-session',
            name: 'Riya Sharma',
            email: 'riya@example.edu',
            role: UserRole.student,
            department: 'Computer Science',
            semester: 5,
            createdAt: DateTime(2025),
            rollNumber: 'CS2023001',
          ),
        );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('DEMO MODE'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Riya Sharma');
    await tester.enterText(find.byType(TextFormField).at(1), 'CS2023001');
    await tester.enterText(find.byType(TextFormField).at(2), '+919876543210');
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.ensureVisible(find.text('Simulate Student Check'));
    await tester.tap(find.text('Simulate Student Check'));
    await tester.pump();
    expect(
      find.text(
        'Sample code: 123456. No SMS is sent and the phone is not verified.',
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField).last, '123456');
    await tester.tap(find.text('Continue Demo'));
    await tester.pumpAndSettle();
    expect(find.text('Sample dashboard'), findsOneWidget);
    router.dispose();
    container.dispose();
  });

  testWidgets('parent registration requires a signed-in student approver', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/register/parent',
      routes: [
        GoRoute(
          path: '/register/parent',
          builder: (_, _) => const ParentRegistrationScreen(),
        ),
        GoRoute(
          path: '/register/select-role',
          builder: (_, _) => const Scaffold(body: Text('Account types')),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Sign In screen')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'A Student must sign in and approve access before a Parent link can be created.',
      ),
      findsOneWidget,
    );
    expect(find.text('Student Sign In'), findsOneWidget);
    await tester.tap(find.text('Student Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Sign In screen'), findsOneWidget);
    router.dispose();
  });

  testWidgets(
    'signed-in Student gets the parent registration and approval form',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      await container
          .read(authStateProvider.notifier)
          .login('student@test.edu', 'password');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ParentRegistrationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Register Parent Access'), findsOneWidget);
      expect(find.text(parentDemoDisclaimer), findsNothing);
      expect(find.text('Student full name'), findsOneWidget);
      expect(find.text('Student roll number'), findsOneWidget);
      expect(find.text('Parent mobile number'), findsOneWidget);
      expect(
        find.text('I approve linking a Parent account to my Student profile.'),
        findsOneWidget,
      );
      expect(find.text('Verify Student and Send OTP'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    },
  );

  testWidgets('student profile back returns to pushed origin', (tester) async {
    final router = GoRouter(
      initialLocation: '/student',
      routes: [
        GoRoute(
          path: '/student',
          builder: (context, _) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => context.push('/student/profile'),
                child: const Text('Open profile'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/student/profile',
          builder: (_, _) => const StudentProfile(),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open profile'), findsOneWidget);
    router.dispose();
  });

  testWidgets('direct student profile link falls back to student dashboard', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/student/profile',
      routes: [
        GoRoute(
          path: '/student',
          builder: (_, _) => const Scaffold(body: Text('Student dashboard')),
        ),
        GoRoute(
          path: '/student/profile',
          builder: (_, _) => const StudentProfile(),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Student dashboard'), findsOneWidget);
    router.dispose();
  });

  testWidgets('admin statistic card fits narrow width and larger text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.8)),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 250,
                height: 240,
                child: AdminStatCard(
                  label: 'Total faculty',
                  value: '128',
                  detail: 'From institution users',
                  icon: Icons.badge_outlined,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
