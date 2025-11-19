import 'package:flutter/material.dart';
import 'package:fluttertemplate/views/camera_view.dart';
import 'package:fluttertemplate/views/main_view.dart';
import 'package:fluttertemplate/views/sub_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Template',
      theme: ThemeData(
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainView(title: 'Flutter Template Home Page'),
        '/sub': (context) => const SubView(),
        '/camera': (context) => const CameraView(),
      },
    );
  }
}
