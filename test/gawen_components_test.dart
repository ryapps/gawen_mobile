import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/gawen_avatar.dart';
import 'package:frontend/core/widgets/gawen_button.dart';
import 'package:frontend/core/widgets/gawen_empty_state.dart';
import 'package:frontend/core/widgets/gawen_loading.dart';
import 'package:frontend/core/widgets/gawen_status_badge.dart';
import 'package:frontend/core/widgets/gawen_text_field.dart';

void main() {
  testWidgets(
    'loading primary button is disabled and keeps its normal height',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: GawenPrimaryButton(
              label: 'Simpan',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.getSize(find.byType(FilledButton)).height, 52);
    },
  );

  testWidgets('multiline field aligns its prefix and exposes suffix action', (
    tester,
  ) async {
    var suffixPressed = false;
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: Form(
                child: GawenTextField(
                  controller: controller,
                  label: 'Deskripsi',
                  hint: 'Tuliskan deskripsi',
                  icon: Icons.notes,
                  maxLines: 4,
                  suffixIcon: Icons.clear,
                  suffixTooltip: 'Hapus',
                  onSuffixPressed: () => suffixPressed = true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.notes), findsOneWidget);
    final suffixButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(suffixButton.onPressed, isNotNull);
    suffixButton.onPressed!();
    expect(suffixPressed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('avatar without an image shows the default icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: GawenAvatar(imageUrl: null, size: 48))),
    );

    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
  });

  testWidgets('status badge and empty state share standard typography', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              GawenStatusBadge(status: GawenStatus.pending),
              GawenEmptyState(
                title: 'Belum ada data',
                description: 'Data akan muncul di sini.',
              ),
              GawenLoading(size: 20),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Menunggu persetujuan'), findsOneWidget);
    expect(find.text('Belum ada data'), findsOneWidget);
    expect(find.text('Data akan muncul di sini.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
