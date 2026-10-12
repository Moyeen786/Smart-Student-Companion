import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/models/user_model.dart';

typedef NotificationTapHandler = void Function(String announcementId);
typedef ForegroundNotificationHandler = void Function(RemoteMessage message);

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;
  bool _initialized = false;
  String? _syncedUserId;
  String? _activeRoleTopic;
  String? _activeDepartmentTopic;
  String? _pendingAnnouncementId;

  NotificationTapHandler? onAnnouncementTap;
  ForegroundNotificationHandler? onForegroundNotification;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessage,
    );
    _tokenSubscription = _messaging.onTokenRefresh.listen(_saveToken);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleMessage(initialMessage);
    _dispatchPendingTap();
  }

  Future<void> syncUser(UserModel? user) async {
    await initialize();
    if (user == null) {
      await _unsubscribeFromTopics();
      _syncedUserId = null;
      return;
    }
    if (_syncedUserId == user.uid) {
      _dispatchPendingTap();
      return;
    }

    _syncedUserId = user.uid;
    final permission = await _requestPermissionIfNeeded(user.uid);
    final token = await _safeGetToken();
    if (token != null) {
      await _saveUserToken(user.uid, token, permission);
    }
    await _subscribeToTopics(user);
    _dispatchPendingTap();
  }

  Future<NotificationSettings> _requestPermissionIfNeeded(String uid) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      final alreadyRequested =
          snapshot.data()?['notificationPermissionRequested'] == true;
      if (alreadyRequested) {
        return await _messaging.getNotificationSettings();
      }
    } catch (_) {
      // Permission setup should not block authentication when the profile is offline.
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    try {
      await _firestore.collection('users').doc(uid).set({
        'notificationPermissionRequested': true,
        'notificationPermission': settings.authorizationStatus.name,
        'notificationPermissionUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // A denied permission or a temporary Firestore failure must not crash the app.
    }
    return settings;
  }

  Future<String?> _safeGetToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    final uid = _auth.currentUser?.uid ?? _syncedUserId;
    if (uid == null) return;
    final permission = await _messaging.getNotificationSettings();
    await _saveUserToken(uid, token, permission);
  }

  Future<void> _saveUserToken(
    String uid,
    String token,
    NotificationSettings permission,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'notificationPermission': permission.authorizationStatus.name,
        'notificationTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Token registration is retried on the next auth/session initialization.
    }
  }

  Future<void> _subscribeToTopics(UserModel user) async {
    final roleTopic = user.role.toFirestoreValue();
    final departmentTopic = _topicForDepartment(user.department);
    try {
      await _messaging.subscribeToTopic('all_users');
      await _messaging.subscribeToTopic(roleTopic);
      if (departmentTopic != null) {
        await _messaging.subscribeToTopic(departmentTopic);
      }
      _activeRoleTopic = roleTopic;
      _activeDepartmentTopic = departmentTopic;
    } catch (_) {
      // Topic support can be unavailable on some platforms/configurations.
    }
  }

  Future<void> _unsubscribeFromTopics() async {
    try {
      if (_activeRoleTopic != null) {
        await _messaging.unsubscribeFromTopic(_activeRoleTopic!);
      }
      if (_activeDepartmentTopic != null) {
        await _messaging.unsubscribeFromTopic(_activeDepartmentTopic!);
      }
      await _messaging.unsubscribeFromTopic('all_users');
    } catch (_) {
      // Best-effort cleanup; the server must still target current user tokens.
    }
    _activeRoleTopic = null;
    _activeDepartmentTopic = null;
  }

  String? _topicForDepartment(String department) {
    final normalized = department.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    return normalized.isEmpty ? null : 'department_$normalized';
  }

  void _handleForegroundMessage(RemoteMessage message) {
    onForegroundNotification?.call(message);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] != 'announcement') return;
    final id = message.data['announcementId'] as String?;
    if (id == null || id.isEmpty) return;
    _pendingAnnouncementId = id;
    _dispatchPendingTap();
  }

  void _dispatchPendingTap() {
    final id = _pendingAnnouncementId;
    final handler = onAnnouncementTap;
    if (id == null || handler == null || _syncedUserId == null) return;
    _pendingAnnouncementId = null;
    handler(id);
  }

  Future<void> enqueueAnnouncement(Announcement announcement) async {
    if (announcement.id.isEmpty) {
      throw StateError(
        'Cannot queue a notification without an announcement ID.',
      );
    }
    final job = _firestore.collection('notification_jobs').doc(announcement.id);
    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(job);
      if (existing.exists) return;
      transaction.set(job, {
        'type': 'announcement',
        'announcementId': announcement.id,
        'title': 'New Announcement',
        'body': announcement.message.isEmpty
            ? announcement.title
            : announcement.message,
        'audience': announcement.audience.value,
        'department': null,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenSubscription?.cancel();
  }
}
