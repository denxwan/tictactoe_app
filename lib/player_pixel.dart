// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class PlayerPixel extends StatelessWidget {
  const PlayerPixel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 37, 228, 174),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
