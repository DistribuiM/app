import 'package:flutter/material.dart';

final WidgetStateProperty<Color?> dataRowPressColor =
    WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.black.withValues(alpha: 0.12);
      }
      return null;
    });
