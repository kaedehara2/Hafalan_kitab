import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hafalan_kitab/login.dart';

import 'grafik.dart';

// ================= IMPORT HALAMAN =================
import 'monitoring.dart';
import 'approvesetoran.dart';

class DashboardAdminPage extends StatefulWidget {

  const DashboardAdminPage({
    super.key,
  });

  @override
  State<DashboardAdminPage> createState() =>
      _DashboardAdminPageState();
}

class _DashboardAdminPageState
    extends State<DashboardAdminPage> {

  final supabase =
      Supabase.instance.client;

  // ================= LOGOUT =================
  Future<void> logout() async {

    final konfirmasi =
        await showDialog<bool>(

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

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
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
          builder: (_) => Login(),
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

            padding:
                const EdgeInsets.all(16),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ================= HEADER =================
                Container(

                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(20),

                  decoration: BoxDecoration(

                    color: Colors.lime[400],

                    borderRadius:
                        BorderRadius.circular(26),
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // ================= LOGOUT =================
                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment.end,

                        children: [

                          Column(

                            children: [

                              IconButton(

                                onPressed:
                                    logout,

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

                          fontWeight:
                              FontWeight.bold,
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

                        padding:
                            const EdgeInsets.all(16),

                        decoration: BoxDecoration(

                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(20),

                          boxShadow: [

                            BoxShadow(

                              color: Colors.grey
                                  .withOpacity(0.15),

                              blurRadius: 6,

                              offset:
                                  const Offset(0, 3),
                            ),
                          ],
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            const Text(

                              'Grafik Monitoring Hafalan',

                              style: TextStyle(

                                fontWeight:
                                    FontWeight.bold,

                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(

                              'Aktivitas Setoran Per Marhalah',

                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ================= GRAFIK =================
                            const Grafik(),
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

                // ================= MENU =================
                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,

                  children: [

                    // ================= MONITORING =================
                    buildMenuItem(

                      icon:
                          Icons.analytics_outlined,

                      title: 'Monitoring',

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const MonitoringPage(),
                          ),
                        );
                      },
                    ),

                    // ================= APPROVE =================
                    buildMenuItem(

                      icon:
                          Icons.fact_check_outlined,

                      title: 'Approve',

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const ApproveKhatamanPage(),
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

                  padding:
                      const EdgeInsets.all(18),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(22),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.grey
                            .withOpacity(0.15),

                        blurRadius: 6,

                        offset:
                            const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Row(

                        children: const [

                          Icon(
                            Icons.info_outline,
                          ),

                          SizedBox(width: 10),

                          Text(

                            'Informasi Sistem',

                            style: TextStyle(

                              fontWeight:
                                  FontWeight.bold,

                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        '• Monitoring digunakan untuk melihat progres hafalan seluruh santri.',
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        '• Approve digunakan untuk menyetujui pengajuan setoran khataman.',
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        '• Admin dapat menentukan jadwal setoran dan memberikan catatan.',
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

    return InkWell(

      onTap: onTap,

      borderRadius:
          BorderRadius.circular(22),

      child: Container(

        width: 140,

        padding:
            const EdgeInsets.symmetric(

          vertical: 24,
          horizontal: 12,
        ),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(22),

          boxShadow: [

            BoxShadow(

              color:
                  Colors.grey.withOpacity(0.15),

              blurRadius: 6,

              offset:
                  const Offset(0, 3),
            ),
          ],
        ),

        child: Column(

          children: [

            Icon(
              icon,
              size: 42,
            ),

            const SizedBox(height: 14),

            Text(

              title,

              style: const TextStyle(

                fontSize: 15,

                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}