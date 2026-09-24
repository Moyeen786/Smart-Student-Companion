import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/features/admin/presentation/create_announcement_screen.dart';
import 'package:smart_student_companion/features/auth/data/repositories/mock_auth_repository.dart';

void main() {
  group('Create announcement form', () {
    testWidgets('shows validation for required fields', (tester) async {
      tester.view.physicalSize = const Size(1400, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          ],
          child: const MaterialApp(
            home: CreateAnnouncementScreen(),
          ),
        ),
      );

      final buttonFinder = find.widgetWithText(ElevatedButton, 'PUBLISH ANNOUNCEMENT');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Announcement title is required.'), findsOneWidget);
      expect(find.text('Announcement message is required.'), findsOneWidget);
    });
  });
}
