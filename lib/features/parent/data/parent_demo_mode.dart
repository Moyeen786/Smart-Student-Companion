import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enable only for local development with:
/// flutter run --dart-define=PARENT_REGISTRATION_DEMO_MODE=true
/// Release/profile builds always ignore this flag.
const parentDemoModeEnabled =
    kDebugMode &&
    bool.fromEnvironment('PARENT_REGISTRATION_DEMO_MODE', defaultValue: false);

final parentDemoModeProvider = Provider<bool>((ref) => parentDemoModeEnabled);

const parentDemoDisclaimer = 'DEMO MODE \u2014 No real account or link created';
const parentDemoOtp = '123456';
