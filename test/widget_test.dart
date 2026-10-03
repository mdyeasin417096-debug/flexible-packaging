import 'package:flexible_packaging/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flexible Packaging app starts', (tester) async {
    await tester.pumpWidget(const FlexiblePackagingApp());

    expect(find.text('Flexible Packaging'), findsWidgets);
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Knowledge'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
