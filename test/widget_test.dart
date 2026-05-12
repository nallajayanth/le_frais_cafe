import 'package:flutter_test/flutter_test.dart';

import 'package:le_frais_mobile_application/main.dart';

void main() {
  testWidgets('Onboarding screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LeFraisApp(isLoggedIn: false));
    expect(find.text('Le Frais'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
