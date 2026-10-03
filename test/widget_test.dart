import 'package:flexible_packaging/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flexible Packaging 15-screen app starts', (tester) async {
    await tester.pumpWidget(const FlexiblePackagingApp());
    expect(find.text('Flexible Packaging'), findsWidgets);
  });
}
