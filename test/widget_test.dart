import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biosphere_codex/ui/screens/hero_screen.dart';

void main() {
  testWidgets('HeroScreen renders title and CTA buttons properly', (WidgetTester tester) async {
    bool enteredCodex = false;

    await tester.pumpWidget(
      MaterialApp(
        home: HeroScreen(
          onEnterCodex: () {
            enteredCodex = true;
          },
        ),
      ),
    );

    // Pompa waktu 200ms agar Future.delayed di initState selesai
    await tester.pump(const Duration(milliseconds: 200));

    // Verifikasi teks judul utama dan tombol CTA
    expect(find.text('BIOSPHERE\nCODEX'), findsOneWidget);
    expect(find.text('Jelajahi Pohon Kehidupan'), findsOneWidget);

    // Uji klik tombol CTA
    await tester.tap(find.text('Jelajahi Pohon Kehidupan'));
    await tester.pump();

    expect(enteredCodex, isTrue);
  });
}
