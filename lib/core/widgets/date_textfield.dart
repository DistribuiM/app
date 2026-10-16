import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTextField extends StatefulWidget {
  const DateTextField({super.key, this.onDateChanged, this.initialDate});

  final Function(String)? onDateChanged;
  final String? initialDate;

  @override
  State<DateTextField> createState() => _DateTextFieldState();
}

class _DateTextFieldState extends State<DateTextField> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = widget.initialDate ?? '';
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: "Data*",
        filled: true,
        prefixIcon: Icon(Icons.calendar_today),
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 25,
        ),
      ),
      readOnly: true,
      onTap: () async {
        DateTime dataInicial;
        try {
          dataInicial = DateFormat(
            'dd/MM/yyyy',
          ).parseStrict(_dateController.text);
        } on FormatException {
          dataInicial = DateTime.now();
        }
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: dataInicial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          setState(() {
            _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          });
          widget.onDateChanged?.call(_dateController.text);
        }
      },
    );
  }
}
