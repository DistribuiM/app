import 'package:flutter/material.dart';

class CheckBox extends StatefulWidget {
  const CheckBox({super.key, required this.label});
  final String label;

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  bool isChecked = true;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      tileColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      title: Text(widget.label),
      value: isChecked,
      onChanged: (bool? value) {
        if (value != null) {
          setState(() {
            isChecked = value;
          });
        }
      },
    );
  }
}