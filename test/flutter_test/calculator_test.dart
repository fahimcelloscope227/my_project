
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/main.dart' as app; // change my_app to your actual package name


void main(){

  group("Calculator Testing", ()  {
    testWidgets("adds two numbers", (tester)async{
      // start app
      await tester.pumpWidget(app.MyApp());

      // find the text fields
      final textFieldA = find.byType(TextFormField).at(0);
      final textFieldB = find.byType(TextFormField).at(1);
      final addButton = find.byType(ElevatedButton).at(0);

      // enter numbers
      await tester.enterText(textFieldA,'5');
      await tester.enterText(textFieldB,'2');

      await tester.tap(addButton);
      await tester.pump();

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets("substract two numbers", (tester)async{
      // start app
      await tester.pumpWidget(app.MyApp());

      // find the text fields
      final textFieldA = find.byType(TextFormField).at(0);
      final textFieldB = find.byType(TextFormField).at(1);
      final substractButton = find.byType(ElevatedButton).at(1);

      // enter numbers
      await tester.enterText(textFieldA,'5');
      await tester.enterText(textFieldB,'2');

      await tester.tap(substractButton);
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
    });
  });
}