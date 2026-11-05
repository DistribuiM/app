import 'package:flutter/material.dart';

final WidgetStateProperty<Color?> dataRowPressColor =
    WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.black.withValues(alpha: 0.12);
      }
      return null;
    });

final WidgetStateProperty<Color?> dataRowSelectedColor =
    WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected) ||
          states.contains(WidgetState.pressed)) {
        return Colors.black.withValues(alpha: 0.25);
      }
      return null;
    });