import 'package:flutter/material.dart';
import 'package:my_project/features/biometric_auth/presentation/biometric_auth_page.dart';
import 'package:my_project/features/loca_auth/presenter/finger_print_auth.dart' show FingerPrintAuth;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

      ),
      initialRoute: "/local_auth",
      routes: {
        "/": (context) => MyHomePage(title: '',),
        "/bio_auth": (context) =>BiometricAuthPage(),
        "/local_auth" : (context) => FingerPrintAuth()
      },
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int sum = 0;
  int sub = 0;
  final controllerA = TextEditingController();
  final controllerB = TextEditingController();



  @override
  void dispose() {
    super.dispose();
    controllerA.dispose();
    controllerB.dispose();
  }

  void add(){
    setState(() {
      sum = int.parse(controllerA.text) + int.parse(controllerB.text);
    });
  }
  void substraction(){
    setState(() {
      sub = (int.parse(controllerA.text) - int.parse(controllerB.text)).abs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(

                controller: controllerA,
              ),
            ),  Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: controllerB,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: add, child: Icon(Icons.add)),
                ElevatedButton(onPressed: substraction, child: Icon(Icons.minimize)),
              ],
            ),

            const Text('You have pushed the button this many times:'),
            Text(
              '$sum',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '$sub',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ],
        ),
      ),
     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
