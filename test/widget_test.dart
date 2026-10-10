import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_student_companion/app/app.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/features/auth/data/repositories/mock_auth_repository.dart';

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

  testWidgets('login navigates to Who are you screen for students', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    // Enter email and password
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;
    await tester.enterText(emailField, 'student@campus.edu');
    await tester.enterText(passwordField, 'password123');

    // Tap LOGIN
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    // Verify navigating to Who are you? page
    expect(find.text('Who are you?'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Parent'), findsOneWidget);

    // Tap Parent
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();

    // Verify Parent Verification screen
    expect(find.text('Parent Verification'), findsOneWidget);
    expect(find.text('Enter your registered mobile number'), findsOneWidget);
    expect(find.text('GET OTP'), findsOneWidget);

    // Enter unregistered phone number and click GET OTP
    final phoneField = find.byType(TextFormField).first;
    await tester.enterText(phoneField, '9111122222');
    await tester.tap(find.text('GET OTP'));
    await tester.pumpAndSettle();

    // Verify inline error and registration link appear
    expect(find.text('Mobile number not registered.'), findsOneWidget);
    expect(
      find.text("Don't have a registered account? Register here"),
      findsOneWidget,
    );

    // Tap "Don't have a registered account? Register here"
    await tester.tap(find.text("Don't have a registered account? Register here"));
    await tester.pumpAndSettle();

    // Verify navigates to Create Your Account page
    expect(find.text('Create Your Account'), findsOneWidget);

    // Scroll to and tap Parent role card
    await tester.ensureVisible(find.text('Parent'));
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();

    // Verify Parent Registration screen fields
    expect(find.text('Parent Registration'), findsOneWidget);
    expect(find.text('Student Full Name'), findsOneWidget);
    expect(find.text('Student Roll Number'), findsOneWidget);
    expect(find.text('Department'), findsOneWidget);
    expect(find.text('Parent Registered Mobile Number'), findsOneWidget);
    expect(find.text('REGISTER'), findsOneWidget);

    // Fill registration form
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Riya Sharma');
    await tester.enterText(textFields.at(1), 'CS2023001');
    await tester.enterText(textFields.at(2), 'CSE');
    await tester.enterText(textFields.at(3), '9876543210');

    // Scroll to and click REGISTER
    await tester.ensureVisible(find.text('REGISTER'));
    await tester.tap(find.text('REGISTER'));
    await tester.pumpAndSettle();

    // Verify navigates back to first Login page
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);

    // Wait for registration feedback SnackBar to dismiss
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // --- Step 5: AFTER REGISTRATION - REPEAT FLOW ---
    final loginEmailField = find.byType(TextFormField).first;
    final loginPasswordField = find.byType(TextFormField).last;
    await tester.enterText(loginEmailField, 'student@campus.edu');
    await tester.enterText(loginPasswordField, 'password123');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    // Who are you? -> Parent
    expect(find.text('Who are you?'), findsOneWidget);
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();

    // Now enter the registered mobile number
    final phoneField2 = find.byType(TextFormField).first;
    await tester.enterText(phoneField2, '9876543210');
    await tester.ensureVisible(find.text('GET OTP'));
    await tester.tap(find.text('GET OTP'));
    await tester.pumpAndSettle();

    // OTP verification section should now be visible on the same page
    expect(find.text('VERIFY OTP'), findsOneWidget);

    // Enter 6 digit OTP (fallback / mock accepts valid OTP or 123456)
    final otpInputFields = find.byType(TextField);
    for (int i = 0; i < 6; i++) {
      await tester.enterText(otpInputFields.at(i), '${i + 1}');
    }
    await tester.ensureVisible(find.text('VERIFY OTP'));
    await tester.tap(find.text('VERIFY OTP'));
    await tester.pumpAndSettle();

    // Parent Dashboard should now open!
    expect(find.text('Parent Dashboard'), findsOneWidget);
  });
}
