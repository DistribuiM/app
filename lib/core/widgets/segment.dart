import 'package:flutter/material.dart';

class Segment {
  final int value;
  final String label;
  final IconData? icon;

  const Segment({required this.value, required this.label, this.icon});
}