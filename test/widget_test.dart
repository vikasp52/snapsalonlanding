import 'package:flutter_test/flutter_test.dart';
import 'package:snap_salon_landing/main.dart';

void main() {
  testWidgets('SnapSalon app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const SnapSalonApp());
    expect(find.text('SnapSalon'), findsWidgets);
  });
}
