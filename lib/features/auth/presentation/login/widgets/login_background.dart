import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;

  const LoginBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -80,
          left: 0,
          right: 0,
          bottom: 0,
          child: Image.asset(
            'assets/images/login_bg.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        // Lớp phủ sáng nhẹ ở phần đầu giúp nổi bật Logo
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.82),
                  Colors.white.withValues(alpha: 0.48),
                  Colors.white.withValues(alpha: 0.28),
                  Colors.white.withValues(alpha: 0.38),
                ],
                stops: const [0.0, 0.24, 0.48, 1.0],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
