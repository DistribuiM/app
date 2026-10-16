import 'package:app_distribuim/core/widgets/date_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('initialDate preenche o campo sem chamar onDateChanged', (
    tester,
  ) async {
    var chamadas = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DateTextField(
            initialDate: '15/10/2026',
            onDateChanged: (_) => chamadas++,
          ),
        ),
      ),
    );

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '15/10/2026',
    );
    expect(chamadas, 0);
  });
}
