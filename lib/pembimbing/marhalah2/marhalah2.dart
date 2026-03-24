import 'package:flutter/material.dart';

class Marhalah2 extends StatelessWidget {
  const Marhalah2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Marhalah 2")),
      body: const Center(
        child: Text(
          "Ini Marhalah 2",
          style: TextStyle(fontSize: 45),
        ),
      ),
    );
  }
}