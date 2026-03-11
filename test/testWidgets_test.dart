import 'package:astrowaypartner/firebase_options.dart';
import 'package:astrowaypartner/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

void main() {
  setupMocks();

  setUpAll(() async {
    // Initialize GetStorage as done in main.dart
    // Note: This might create a timer that persists.
    await GetStorage.init();
    
    // Initialize default app (required by FirebaseFirestore.instance)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.android,
    );
    // Initialize named app (as done in main.dart)
    await Firebase.initializeApp(
      name: 'AstrowayPartner',
      options: DefaultFirebaseOptions.android,
    );
  });

  testWidgets('Test app builds correctly', (WidgetTester tester) async {
    Get.testMode = true;

    // Provide EasyLocalization for the test
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'US')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        startLocale: const Locale('en', 'US'),
        child: const MyApp(),
      ),
    );
    
    // Use pumpAndSettle to wait for animations and initializations
    // If it fails with timeout, we'll revert to multiple pumps.
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}

class MockFirebasePlatform extends FirebasePlatform {
  final Map<String, FirebaseAppPlatform> _apps = {};

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final appName = name ?? defaultFirebaseAppName;
    final app = MockFirebaseApp(appName, options!);
    _apps[appName] = app;
    return app;
  }

  @override
  List<FirebaseAppPlatform> get apps => _apps.values.toList();

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    if (_apps.containsKey(name)) return _apps[name]!;
    if (name == defaultFirebaseAppName && _apps.isNotEmpty) {
      return _apps.values.first;
    }
    throw Exception('App $name does not exist. Available apps: ${_apps.keys.join(", ")}');
  }
}

class MockFirebaseApp extends FirebaseAppPlatform {
  MockFirebaseApp(super.name, super.options);
}

void setupMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock Firebase Platform
  FirebasePlatform.instance = MockFirebasePlatform();

  // Mock Messaging
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/firebase_messaging'), (call) async {
    if (call.method == 'Messaging#getToken') return 'mock_token';
    if (call.method == 'Messaging#requestPermission') {
      return {
        'alert': true,
        'announcement': false,
        'badge': true,
        'carPlay': false,
        'criticalAlert': false,
        'provisional': false,
        'sound': true,
      };
    }
    return null;
  });
  
  // Mock OneSignal
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('OneSignal'), (call) async => null);
      
  // Mock CallKit
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('flutter_callkit_incoming'), (call) async => null);

  // Mock Connectivity
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('dev.fluttercommunity.plus/connectivity'), (call) async => 'wifi');

  // Mock Package Info
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('dev.fluttercommunity.plus/package_info'), (call) async {
    return {'appName': 'App', 'packageName': 'com.app', 'version': '1.0', 'buildNumber': '1'};
  });
  
  // Mock SharedPreferences
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/shared_preferences'), (call) async {
    if (call.method == 'getAll') return <String, dynamic>{};
    return null;
  });

  // Mock PathProvider
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (call) async {
    return '.';
  });
  
  // Mock Firestore channel
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/cloud_firestore'), (call) async => null);
}
