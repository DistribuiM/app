import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final Function()? onPressed;
  const CustomElevatedButton({super.key, this.onPressed});

  @override

  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              kIsWeb ? 'images/google.png' : 'assets/images/google.png',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 16),
            Text(
              'Entrar com Google', 
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      )
    );
  }
}