import 'package:flutter/material.dart';

class BabulMinanPage extends StatelessWidget {
  const BabulMinanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitab Babul Minan"),
        backgroundColor: Colors.lime[400],
      ),
      body: const Center(
        child: Text(
          "Halaman Babul Minan\n(akan dikembangkan)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
