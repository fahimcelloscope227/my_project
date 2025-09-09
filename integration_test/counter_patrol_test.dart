import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:my_project/main.dart' as app; // change my_app to your actual package name

void main() {
  patrolTest("Counter Increment Test", ($) async {
    // start App
    await $.pumpWidgetAndSettle(app.MyApp());

    // verify initial value is 0
    expect($(Text).containing('0'), findsOneWidget);

    // Tap the add button
    await $(FloatingActionButton).tap();

    expect($(Text).containing('1'), findsOneWidget);

  });
}