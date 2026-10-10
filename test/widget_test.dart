import 'package:flutter_test/flutter_test.dart';
import 'package:pro/ui/app.dart';

void main() {
  testWidgets('Ana ekran açılır ve kategoriler görünür', (tester) async {
    await tester.pumpWidget(const TechnikalcApp());
    await tester.pumpAndSettle();
    expect(find.text('Teknik Hesap Makinesi'), findsOneWidget);
    expect(find.text('Elektrik'), findsOneWidget);
    expect(find.text('Kablo'), findsOneWidget);
  });
}
