import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/app/router.dart';
import 'package:smart_student_companion/core/theme/app_theme.dart';
import 'package:smart_student_companion/models/user_model.dart';

final appScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authStateProvider);
    FirebaseApp? firebaseApp;
    try {
      firebaseApp = Firebase.app();
    } catch (_) {
      firebaseApp = null;
    }
    if (firebaseApp != null) {
      final notificationService = ref.watch(notificationServiceProvider);
      notificationService.onAnnouncementTap = (announcementId) {
        final role = ref.read(authStateProvider).valueOrNull?.user?.role;
        router.go(
          role == UserRole.admin
              ? '/admin/announcements/$announcementId'
              : '/announcements/$announcementId',
        );
      };
      notificationService.onForegroundNotification = (message) {
        _showForegroundNotification(router, ref, message);
      };
      unawaited(notificationService.initialize());
      unawaited(notificationService.syncUser(authState.valueOrNull?.user));
    }

    return MaterialApp.router(
      title: 'Smart Student Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      routerConfig: router,
    );
  }

  void _showForegroundNotification(
    GoRouter router,
    WidgetRef ref,
    RemoteMessage message,
  ) {
    final title = message.notification?.title ?? 'New notification';
    final body = message.notification?.body;
    final announcementId = message.data['announcementId'] as String?;
    final role = ref.read(authStateProvider).valueOrNull?.user?.role;
    appScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(body == null || body.isEmpty ? title : '$title\n$body'),
        action: announcementId == null
            ? null
            : SnackBarAction(
                label: 'OPEN',
                onPressed: () => router.go(
                  role == UserRole.admin
                      ? '/admin/announcements/$announcementId'
                      : '/announcements/$announcementId',
                ),
              ),
      ),
    );
  }
}
