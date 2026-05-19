import 'package:flutter/material.dart';

class ImrithiPage extends StatelessWidget {
  const ImrithiPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitab Nadzam Imriti"),
        backgroundColor: Colors.lime[400],
      ),
      body: const Center(
        child: Text(
          "Halaman Nadzam Imriti\n(akan dikembangkan)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
