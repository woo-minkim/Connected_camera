import 'package:flutter/material.dart';
import 'package:fluttertemplate/theme/app_theme.dart';
import 'package:fluttertemplate/widgets/glass_card.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Scenic Background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2940&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback gradient if offline
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 2. Center Card
          Center(
            child: GlassCard(
              width: 400,
              padding: const EdgeInsets.all(40),
              borderRadius: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Welcome Home",
                    style: AppTextStyles.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Scan to log in instantly",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // QR Code Placeholder
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 140,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Alternative: Profile Avatars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAvatar(context, "Dad", Colors.blueAccent),
                      const SizedBox(width: 16),
                      _buildAvatar(context, "Mom", Colors.orangeAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String name, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3), width: 2),
              ),
              child: Icon(Icons.person, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: AppTextStyles.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
