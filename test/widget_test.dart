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
}
