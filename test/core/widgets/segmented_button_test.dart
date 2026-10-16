import 'package:app_distribuim/core/widgets/segment.dart';
import 'package:app_distribuim/core/widgets/segmented_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const segments = [
    Segment(value: 1, label: 'Primeiro'),
    Segment(value: 2, label: 'Segundo'),
  ];

  testWidgets('initialValue seleciona o segmento indicado', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomSegmentedButton(segments: segments, initialValue: 2),
        ),
      ),
    );

    final segmentedButton = tester.widget<SegmentedButton<int>>(
      find.byType(SegmentedButton<int>),
    );
    expect(segmentedButton.selected, {2});
  });

  testWidgets('sem initialValue seleciona o primeiro segmento', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CustomSegmentedButton(segments: segments)),
      ),
    );

    final segmentedButton = tester.widget<SegmentedButton<int>>(
      find.byType(SegmentedButton<int>),
    );
    expect(segmentedButton.selected, {1});
  });
}
