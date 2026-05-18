import 'package:flutter/material.dart';

class AlfiyahPage extends StatelessWidget {
  const AlfiyahPage ({super.key});

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitab Nadzam Alfiyah"),
        backgroundColor: Colors.lime[400],
      ),
      body: const Center(
        child: Text(
          "Halaman Nadzam Alfiyah\n(akan dikembangkan)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
