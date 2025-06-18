import 'package:flutter/material.dart';

void main() {
  runApp(const {{project_name.pascalCase()}}App());
}

class {{project_name.pascalCase()}}App extends StatelessWidget {
  const {{project_name.pascalCase()}}App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '{{project_name.titleCase()}}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const {{project_name.pascalCase()}}HomePage(title: '{{project_name.titleCase()}} Home Page'),
    );
  }
}

class {{project_name.pascalCase()}}HomePage extends StatefulWidget {
  const {{project_name.pascalCase()}}HomePage({super.key, required this.title});

  final String title;

  @override
  State<{{project_name.pascalCase()}}HomePage> createState() => _{{project_name.pascalCase()}}HomePageState();
}

class _{{project_name.pascalCase()}}HomePageState extends State<{{project_name.pascalCase()}}HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
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
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}