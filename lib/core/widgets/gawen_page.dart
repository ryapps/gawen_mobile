import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GawenPage extends StatelessWidget {
  const GawenPage({
    super.key,
    required this.child,
    this.appBar,
    this.padding = const EdgeInsets.symmetric(
      horizontal: GawenSpacing.pageHorizontal,
      vertical: GawenSpacing.pageVertical,
    ),
    this.backgroundColor,
    this.scrollable = true,
    this.safeArea = true,
    this.bottomNavigationBar,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool scrollable;
  final bool safeArea;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: scrollable ? SingleChildScrollView(child: child) : child,
    );
    if (safeArea) content = SafeArea(child: content);
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
