import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/main.dart';

Future<void> theAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
}
