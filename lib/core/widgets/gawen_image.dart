import 'package:flutter/material.dart';

class GawenImage extends StatelessWidget {
  const GawenImage({
    required this.source,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.assetFallback = fallbackAsset,
    super.key,
  });

  static const fallbackAsset = 'assets/icons/avatar.png';

  final String? source;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final String? assetFallback;

  @override
  Widget build(BuildContext context) {
    final value = source?.trim();
    final child = value == null || value.isEmpty
        ? _fallback()
        : _isNetworkUrl(value)
        ? Image.network(
            value,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _fallback(),
          )
        : Image.asset(
            value,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _fallback(),
          );
    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _fallback() {
    final asset = assetFallback;
    if (asset == null || asset.isEmpty) {
      return SizedBox(width: width, height: height);
    }
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => SizedBox(width: width, height: height),
    );
  }

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
