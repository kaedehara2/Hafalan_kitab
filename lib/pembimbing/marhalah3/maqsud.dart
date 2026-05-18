import 'package:flutter/material.dart';

class MaqsudPage extends StatelessWidget {
  const MaqsudPage ({super.key});

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitab Nadzam Maqsud"),
        backgroundColor: Colors.lime[400],
      ),
      body: const Center(
        child: Text(
          "Halaman Nadzam Maqsud\n(akan dikembangkan)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
