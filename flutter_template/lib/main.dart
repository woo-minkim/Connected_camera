import 'package:flutter/material.dart';
import 'package:fluttertemplate/controllers/face_detection_controller.dart';
import 'package:fluttertemplate/theme/app_theme.dart';
import 'package:fluttertemplate/views/camera_view.dart';
import 'package:fluttertemplate/views/home_view.dart';
import 'package:fluttertemplate/views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the controller
  final faceDetectionController = FaceDetectionController();
  faceDetectionController.initialize();

  runApp(MyApp(controller: faceDetectionController));
}

class MyApp extends StatelessWidget {
  final FaceDetectionController controller;

  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FaceDetectionScope(
      controller: controller,
      child: MaterialApp(
        title: 'Flutter webOS Soft UI',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.accentBlue,
            surface: AppColors.surface,
            brightness: Brightness.light, // Soft UI is Light Mode
          ),
          fontFamily: 'Roboto',
        ),
        // Start with Login View
        home: const LoginView(),
        routes: {
          '/login': (context) => const LoginView(),
          '/home': (context) => const HomeView(),
          '/camera': (context) => const CameraView(),
        },
      ),
    );
  }
}
