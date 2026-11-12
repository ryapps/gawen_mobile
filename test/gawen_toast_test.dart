import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/widgets/gawen_toast.dart';

void main() {
  testWidgets('toast displays its content and can be dismissed', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (buildContext) {
            context = buildContext;
            return const Scaffold(body: Text('Page content'));
          },
        ),
      ),
    );

    GawenToast.success(
      context,
      message: 'Data berhasil disimpan.',
      duration: const Duration(minutes: 1),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Berhasil'), findsOneWidget);
    expect(find.text('Data berhasil disimpan.'), findsOneWidget);
    expect(find.byTooltip('Tutup notifikasi'), findsOneWidget);

    await tester.tap(find.byTooltip('Tutup notifikasi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Data berhasil disimpan.'), findsNothing);
  });

  testWidgets('new toast replaces the toast currently on screen', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (buildContext) {
            context = buildContext;
            return const Scaffold(body: Text('Page content'));
          },
        ),
      ),
    );

    GawenToast.info(
      context,
      message: 'Informasi lama.',
      duration: const Duration(minutes: 1),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    GawenToast.error(
      context,
      message: 'Informasi terbaru.',
      duration: const Duration(minutes: 1),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Informasi lama.'), findsNothing);
    expect(find.text('Terjadi Kesalahan'), findsOneWidget);
    expect(find.text('Informasi terbaru.'), findsOneWidget);

    await tester.tap(find.byTooltip('Tutup notifikasi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
  });

  testWidgets('toast dismisses itself after its duration', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (buildContext) {
            context = buildContext;
            return const Scaffold(body: Text('Page content'));
          },
        ),
      ),
    );

    GawenToast.warning(
      context,
      message: 'Perhatian.',
      duration: const Duration(seconds: 1),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Perhatian.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Perhatian.'), findsNothing);
  });
}
