import 'package:flutter/material.dart';

import 'awamil.dart';
import 'babulminan.dart';
import '../marhalah2/jurumiyah.dart';

class PilihKitabPage extends StatelessWidget {

  final String username;

  const PilihKitabPage({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Pilih Kitab Hafalan",
        ),
        backgroundColor: Colors.lime[400],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [

            // ================= MARHALAH 1 =================
            const Text(
              "Marhalah 1",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _buildKitabCard(
              context,
              title: "Kitab Awamil",
              subtitle: "Dasar Nahwu",
              onTap: () {

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => AwamilPage(
                      username: username,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _buildKitabCard(
              context,
              title: "Kitab Babul Minan",
              subtitle: "Marhalah 1",
              onTap: () {

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => const BabulMinanPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // ================= MARHALAH 2 =================
            const Text(
              "Marhalah 2",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _buildKitabCard(
              context,
              title: "Kitab Jurumiyah",
              subtitle: "Nahwu Menengah",
              onTap: () {

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => JurumiyahPage(
                      username: username,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD KITAB =================
  Widget _buildKitabCard(
    BuildContext context, {

    required String title,
    required String subtitle,
    required VoidCallback onTap,

  }) {

    return InkWell(

      onTap: onTap,

      borderRadius: BorderRadius.circular(18),

      child: Container(

        width: double.infinity,

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.lime[300],
          borderRadius: BorderRadius.circular(18),
        ),

        child: Row(
          children: [

            const Icon(
              Icons.menu_book,
              size: 40,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}