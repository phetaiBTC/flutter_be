import 'package:flutter/material.dart';
import 'package:learning/screens/users.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hello world',
      debugShowCheckedModeBanner: false, //banner Logo flutter
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home:SignUp(),
      home: UsersScreen(),
    );
  }
}
