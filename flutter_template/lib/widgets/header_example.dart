import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 60,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
