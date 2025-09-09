
import 'package:my_project/calculator.dart';
import 'package:test/test.dart';

void main(){

  test('when add 2 and 2 calculator return 4',(){
    final calculator = Calculator();

    final result = calculator.add(2, 2);

    expect(result, 4);
  });

}
