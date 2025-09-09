import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/main.dart' as app; // change my_app to your actual package name

void main(){
  group("Counter Test", (){
    testWidgets("CounterApp Init", (tester) async {
      await tester.pumpWidget(app.MyApp());
      
      expect(find.byType(Text), findsNWidgets(3));
    });

    testWidgets("Counter Increment by 1", (tester) async {
      await tester.pumpWidget(app.MyApp());

      // Action
     await tester.tap(find.byType(FloatingActionButton));
     await tester.pump();

      expect(find.text('1'),findsOneWidget);


    });
  });
}