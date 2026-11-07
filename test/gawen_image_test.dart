import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/widgets/gawen_image.dart';

void main() {
  testWidgets('empty and null sources use the default avatar asset', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            GawenImage(source: null, width: 40, height: 40),
            GawenImage(source: '  ', width: 40, height: 40),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final images = tester.widgetList<Image>(find.byType(Image));
    expect(
      images
          .map((image) => image.image)
          .whereType<AssetImage>()
          .map((image) => image.assetName),
      everyElement(GawenImage.fallbackAsset),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('HTTP and HTTPS sources use network images', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            GawenImage(source: 'http://example.test/a.png'),
            GawenImage(source: 'https://example.test/b.png'),
          ],
        ),
      ),
    );

    expect(
      tester.widgetList<Image>(find.byType(Image)).map((image) => image.image),
      everyElement(isA<NetworkImage>()),
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('asset paths use assets and failed assets fall back', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            GawenImage(
              source: 'assets/icons/building.png',
              width: 40,
              height: 40,
            ),
            GawenImage(
              source: 'assets/icons/missing.png',
              width: 40,
              height: 40,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final assets = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .whereType<AssetImage>()
        .map((image) => image.assetName)
        .toList();
    expect(assets, contains('assets/icons/building.png'));
    expect(assets, contains(GawenImage.fallbackAsset));
    expect(tester.takeException(), isNull);
  });
}
