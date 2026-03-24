import 'package:flutter/material.dart';

class Marhalah3 extends StatelessWidget {
  const Marhalah3 ({super.key});

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Marhalah 3")),
      body: const Center(
        child: Text(
          "Ini Marhalah 3",
          style: TextStyle(fontSize: 45),
        ),
      ),
    );
  }
}