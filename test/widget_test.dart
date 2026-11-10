import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Finance Tracker tabs smoke test with Settings and Currency', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const FinanceTrackerApp());
    await tester.pumpAndSettle();

    // Verify that "My Accounts" is displayed.
    expect(find.text('My Accounts'), findsWidgets);

    // Tap on the "My Goals" navigation destination.
    await tester.tap(find.text('My Goals'));
    await tester.pumpAndSettle();

    // Verify that "My Goals" is displayed and Your Goals header appears.
    expect(find.text('My Goals'), findsWidgets);
    expect(find.text('Your Goals'), findsOneWidget);

    // Tap on the "Settings" navigation destination.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify that "Settings" is displayed along with Dark Theme switch.
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Dark Theme'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
  });
}
