import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertemplate/theme/app_theme.dart';

class HolographicContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isActive;

  const HolographicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.isActive = false,
  });

  @override
  State<HolographicContainer> createState() => _HolographicContainerState();
}

class _HolographicContainerState extends State<HolographicContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.holoCyan.withOpacity(0.1)
                : Colors.black.withOpacity(0.4),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.holoCyan
                  : AppColors.holoCyan.withOpacity(0.3),
              width: widget.isActive ? 2 : 1,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppColors.holoCyan.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
            // Chamfered edges for "Cyberpunk" look
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(2),
            ),
          ),
          child: Stack(
            children: [
              widget.child,
              // Scanning line effect
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [
                              _controller.value - 0.2,
                              _controller.value,
                              _controller.value + 0.2
                            ],
                            colors: [
                              Colors.transparent,
                              AppColors.holoCyan.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
