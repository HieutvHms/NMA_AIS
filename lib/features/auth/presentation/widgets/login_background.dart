import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;

  const LoginBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/login_bg.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        // Lớp phủ sáng nhẹ ở phần đầu giúp nổi bật Logo & tiêu đề "AIS Manager"
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.72),
                  Colors.white.withValues(alpha: 0.25),
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.15),
                ],
                stops: const [0.0, 0.28, 0.55, 1.0],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

