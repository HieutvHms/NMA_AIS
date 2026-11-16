import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ais/app/app.dart';
import 'package:ais/app/di/injection_container.dart';

void main() {
  testWidgets('AIS App renders LoginScreen when unauthenticated', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await setupDependencies();
    await tester.pumpWidget(const AisApp());
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
