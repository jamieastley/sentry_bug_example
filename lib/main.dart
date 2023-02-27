import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const dsn = String.fromEnvironment('dsn');

class NavArguments {
  final String text;
  final int number;

  const NavArguments(this.text, this.number);

  @override
  String toString() => 'NavArguments(text: $text, number: $number)';
}

Breadcrumb? sanitiseBreadcrumb(Breadcrumb? breadcrumb, {dynamic hint}) {
  final sanitisedData = Map<String, dynamic>.from(breadcrumb?.data ?? {})
    ..remove('from_arguments')
    ..remove('to_arguments');

  return breadcrumb?.copyWith(data: sanitisedData);
}

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = dsn
        ..beforeBreadcrumb = sanitiseBreadcrumb;
    },
    // Init your App.
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentry Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [
        SentryNavigatorObserver(
          setRouteNameAsTransaction: true,
        )
      ],
      onGenerateRoute: (settings) {
        if (settings.name == '/child') {
          return MaterialPageRoute(
            builder: (context) => const ChildPage(),
            settings: settings,
          );
        }
        return MaterialPageRoute(builder: (context) => const MyHomePage());
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentry'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Home page'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/child',
            arguments: NavArguments(
              'Some data string',
              Random().nextInt(11),
            ),
          );
        },
        tooltip: 'Push child page',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ChildPage extends StatelessWidget {
  const ChildPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This is the child page'),
            ElevatedButton(
              onPressed: () => throw Exception('Logging breadcrumbs to Sentry'),
              child: const Text('Throw exception'),
            ),
          ],
        ),
      ),
    );
  }
}
