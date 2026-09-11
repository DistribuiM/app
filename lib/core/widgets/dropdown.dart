import 'package:flutter/material.dart';
class Dropdown extends StatelessWidget {
  const Dropdown({super.key, required this.options, required this.hintText, this.onChanged});
  final List<String> options;
  final String hintText;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return DropdownMenu<String>(
            width: constraints.maxWidth,
            expandedInsets: EdgeInsets.zero,
            hintText: hintText,
            menuHeight: 300,

            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
                ),
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
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

            dropdownMenuEntries: options.map(
              (option) => DropdownMenuEntry(
                value: option,
                label: option,
                style: ButtonStyle(
                  padding: WidgetStatePropertyAll(
                    const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  textStyle: WidgetStatePropertyAll(
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
            )).toList(),

            onSelected: onChanged,
          );
        }
      )
    );
  }
}