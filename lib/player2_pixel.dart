// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Player2Pixel extends StatelessWidget {
  const Player2Pixel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
