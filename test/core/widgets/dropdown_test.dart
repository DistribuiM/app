import 'package:app_distribuim/core/widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the initial selection in the field', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Dropdown(
            options: ['Selecionado', 'Outro'],
            hintText: 'Escolha',
            initialSelection: 'Selecionado',
          ),
        ),
      ),
    );

    expect(find.text('Selecionado'), findsOneWidget);
  });

  testWidgets('shows the hint when there is no initial selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Dropdown(
            options: ['Selecionado', 'Outro'],
            hintText: 'Escolha',
          ),
        ),
      ),
    );

    expect(find.text('Escolha'), findsOneWidget);
  });
}
