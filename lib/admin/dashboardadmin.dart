import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hafalan_kitab/login.dart';

import 'grafik.dart';

// ================= IMPORT HALAMAN =================
import 'monitoring.dart';
import 'approvesetoran.dart';
import 'monitoring_absensi_page.dart'; // Halaman Monitoring Absensi Pimpinan

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({
    super.key,
  });

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  final supabase = Supabase.instance.client;

  // ================= LOGOUT =================
  Future<void> logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Logout',
          ),
          content: const Text(
            'Apakah Anda yakin ingin logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true) {
      await supabase.auth.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const Login(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.lime[400],
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= LOGOUT =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                onPressed: logout,
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                  size: 28,
                                ),
                              ),
                              const Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ================= TEXT =================
                      const Text(
                        'Selamat Datang',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        '(Pengasuh/Pengurus Pesantren)',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ================= CARD GRAFIK =================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Grafik Monitoring Hafalan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Aktivitas Setoran Per Marhalah',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 20),

                            // ================= GRAFIK =================
                            Grafik(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ================= MENU TITLE =================
                const Text(
                  'Menu Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                // ================= MENU GRID/WRAP =================
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.start,
                  children: [
                    // ================= MONITORING =================
                    buildMenuItem(
                      icon: Icons.analytics_outlined,
                      title: 'Monitoring',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MonitoringPage(),
                          ),
                        );
                      },
                    ),

                    // ================= APPROVE =================
                    buildMenuItem(
                      icon: Icons.fact_check_outlined,
                      title: 'Approve',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ApproveKhatamanPage(),
                          ),
                        );
                      },
                    ),

                    // ================= ABSENSI MONITORING =================
                    buildMenuItem(
                      icon: Icons.how_to_reg_outlined,
                      title: 'Absensi',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MonitoringAbsensiPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ================= INFO BOX =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Informasi Sistem',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      Text(
                        '• Monitoring digunakan untuk melihat progres hafalan seluruh santri.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Approve digunakan untuk menyetujui pengajuan setoran khataman.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Absensi digunakan untuk memantau rekapitulasi kehadiran setoran harian santri per marhalah.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= WIDGET MENU =================
  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    // Menyesuaikan lebar item agar fleksibel di berbagai ukuran layar
    final double cardWidth = (MediaQuery.of(context).size.width - 56) / 3;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: cardWidth < 105 ? 105 : cardWidth,
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 38,
              color: Colors.black87,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}