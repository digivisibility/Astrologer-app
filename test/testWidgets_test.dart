import 'package:astrowaypartner/firebase_options.dart';
import 'package:astrowaypartner/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Firebase explicitly for tests using Android options.
    // This avoids platform issues on macOS/Linux test runners.
    await Firebase.initializeApp(
      name: 'AstrowayPartner',
      options: DefaultFirebaseOptions.android,
    );
  });

  testWidgets('Test Firebase initialization', (WidgetTester tester) async {
    // Build the app and trigger a frame. If Firebase is not initialized
    // correctly, this will throw and the test will fail.
    await tester.pumpWidget(const MyApp());
  });
}
