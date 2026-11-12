import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/widgets/gawen_popup_menu_button.dart';

void main() {
  testWidgets('popup menu returns the selected action', (tester) async {
    bool? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GawenPopupMenuButton<bool>(
            label: 'Tinjau permintaan',
            actions: const [
              GawenPopupMenuAction(
                value: false,
                label: 'Tolak',
                icon: Icons.close_rounded,
                isDestructive: true,
              ),
              GawenPopupMenuAction(
                value: true,
                label: 'Terima',
                icon: Icons.check_rounded,
              ),
            ],
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tinjau permintaan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tolak'));
    await tester.pumpAndSettle();

    expect(selected, false);
  });
}
