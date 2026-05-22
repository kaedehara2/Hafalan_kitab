import 'package:flutter/material.dart';

import 'marhalah1/awamil.dart';
import 'marhalah1/babulminan.dart';

import 'marhalah2/jurumiyah.dart';

import 'marhalah3/imrithi.dart';
import 'marhalah3/maqsud.dart';
import 'marhalah4/alfiyah.dart';

class PilihKitabPage extends StatelessWidget {
  final String username;
  final String marhalah;

  const PilihKitabPage({
    super.key,
    required this.username,
    required this.marhalah,
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

      backgroundColor: Colors.grey[200],

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [

            // ================= MARHALAH 1 =================
            if (marhalah == 'Marhalah 1') ...[

              const Text(
                "Marhalah 1",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

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
                      builder: (_) =>
                          const BabulMinanPage(),
                    ),
                  );
                },
              ),
            ],

            // ================= MARHALAH 2 =================
            if (marhalah == 'Marhalah 2') ...[

              const Text(
                "Marhalah 2",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

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

            // ================= MARHALAH 3 =================
                if (marhalah == 'Marhalah 3') ...[

                  const Text(
                    "Marhalah 3",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildKitabCard(
                    context,
                    title: "Kitab Nadhom Imrithi",
                    subtitle: "Nahw Nadzam Per-Bait",
                    onTap: () {

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => ImrithiPage(

                            username:
                                username,

                    ),
                  ),
                );
                },
              ),

              const SizedBox(height: 16),

              _buildKitabCard(
                context,
                title: "Kitab Nadhom Maqsud",
                subtitle: "Dalam Pengembangan",
                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          MaqsudPage(
                            username: username,
                          ),
                    ),
                  );
                },
              ),
            ],

            // ================= MARHALAH 4 =================
            if (marhalah == 'Marhalah 4') ...[

              const Text(
                "Marhalah 4",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _buildKitabCard(
                context,
                title: "Kitab Alfiyah Ibn Malik",
                subtitle: "Dalam Pengembangan",
                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                           AlfiyahPage(
                            username: username,
                           ),
                    ),
                  );
                },
              ),
            ],
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