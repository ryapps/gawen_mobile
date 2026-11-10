import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GawenTitle extends StatelessWidget {
  const GawenTitle(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    style: GawenTextStyles.title.merge(style),
  );
}

class GawenSectionTitle extends StatelessWidget {
  const GawenSectionTitle(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    style: GawenTextStyles.sectionTitle.merge(style),
  );
}

class GawenBodyText extends StatelessWidget {
  const GawenBodyText(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    style: GawenTextStyles.body.merge(style),
  );
}

class GawenCaption extends StatelessWidget {
  const GawenCaption(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    style: GawenTextStyles.caption.merge(style),
  );
}

class GawenLabel extends StatelessWidget {
  const GawenLabel(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    style: GawenTextStyles.label.merge(style),
  );
}
