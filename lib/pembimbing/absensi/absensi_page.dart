import 'package:flutter/material.dart';

class AbsensiPage extends StatelessWidget {
  const AbsensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Absensi Santri"),
        backgroundColor: Colors.lime,
      ),
      body: const Center(
        child: Text(
          "Halaman Absensi Santri",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}