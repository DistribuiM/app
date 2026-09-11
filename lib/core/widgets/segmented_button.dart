import 'package:flutter/material.dart';
import 'segment.dart';

class CustomSegmentedButton extends StatefulWidget {
  const CustomSegmentedButton({super.key, required this.segments, this.onSelectionChanged});
  final List<Segment> segments;
  final Function(int)? onSelectionChanged;

  @override
  State<CustomSegmentedButton> createState() => _CustomSegmentedButtonState();
}

class _CustomSegmentedButtonState extends State<CustomSegmentedButton> {
  late int selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.segments.first.value;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<int>(
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          selectedForegroundColor: Colors.white,
          selectedBackgroundColor: Colors.green,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: 0, vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        segments: widget.segments.map((segment) {
          return ButtonSegment<int>(
            value: segment.value,
            label: Text(segment.label),
            icon: segment.icon == null ? null : Icon(segment.icon)
          );
        }).toList(),
        selected: <int>{selectedValue},
        onSelectionChanged: (Set<int> newSelection) {
          if (newSelection.isNotEmpty) {
            setState(() {
              selectedValue = newSelection.first;
            });

            widget.onSelectionChanged?.call(newSelection.first);
          }
        },
      ),
    );
  }
}