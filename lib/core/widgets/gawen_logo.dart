import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GawenLogo extends StatelessWidget {
  const GawenLogo({super.key, this.light = false, this.large = false});

  final bool light;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : GawenColors.primaryDark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: large ? 38 : 30,
          height: large ? 38 : 30,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: light ? Colors.white : GawenColors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(11),
              topRight: Radius.circular(11),
              bottomRight: Radius.circular(11),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LogoBar(height: 9, light: light),
              const SizedBox(width: 2),
              _LogoBar(height: 15, light: light),
              const SizedBox(width: 2),
              _LogoBar(height: 11, light: light),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Text(
          'gawen',
          style: TextStyle(
            color: color,
            fontSize: large ? 27 : 23,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _LogoBar extends StatelessWidget {
  const _LogoBar({required this.height, required this.light});

  final double height;
  final bool light;

  @override
  Widget build(BuildContext context) => Container(
    width: 4,
    height: height,
    decoration: BoxDecoration(
      color: light ? GawenColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}
