import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'monitoringhafalan.dart';
import 'riwayatkhataman.dart';
import 'package:hafalan_kitab/login.dart';
import 'chat/chat_page_wali.dart';

class DashboardWaliPage extends StatefulWidget {
  final String waliId;
  final String namaWali;

  const DashboardWaliPage({
    super.key,
    required this.waliId,
    required this.namaWali,
  });

  @override
  State<DashboardWaliPage> createState() => _DashboardWaliPageState();
}

class _DashboardWaliPageState extends State<DashboardWaliPage> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  Map<String, dynamic>? santri;
  List<Map<String, dynamic>> progressKitab = [];

  @override
  void initState() {
    super.initState();
    fetchDataSantri();
  }

  // ================= FETCH SANTRI =================
  Future<void> fetchDataSantri() async {
    setState(() {
      loading = true;
    });

    try {
      final data = await supabase
          .from('santri')
          .select()
          .eq('wali_id', int.parse(widget.waliId))
          .maybeSingle();

      if (data == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      santri = data;
      await loadProgressKitab(santri!['id']);

      if (!mounted) return;
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data: $e')),
      );
    }
  }

  // ================= LOAD PROGRESS =================
  Future<void> loadProgressKitab(int santriId) async {
    progressKitab.clear();

    try {
      final hafalan = await supabase
          .from('hafalan_santri')
          .select()
          .eq('santri_id', santriId);

      Map<String, double> totalProgress = {};
      Map<String, int> totalBait = {};
      Map<String, int> totalSetoran = {};

      for (var item in hafalan) {
        final kitab = item['kitab'].toString().toLowerCase().trim();

        // Kitab Nadzam
        if (kitab == 'imrithi' || kitab == 'maqsud' || kitab == 'alfiyah') {
          final jumlahBait = int.tryParse(item['jumlah_bait']?.toString() ?? '0') ?? 0;
          totalBait[kitab] = (totalBait[kitab] ?? 0) + jumlahBait;
        }
        // Kitab Non Nadzam
        else {
          totalSetoran[kitab] = (totalSetoran[kitab] ?? 0) + 1;
        }
      }

      // Hitung Nadzam
      totalBait.forEach((kitab, jumlah) {
        double progress = 0;
        if (kitab == 'imrithi') {
          progress = (jumlah / 254) * 100;
        } else if (kitab == 'maqsud') {
          progress = (jumlah / 113) * 100;
        } else if (kitab == 'alfiyah') {
          progress = (jumlah / 1002) * 100;
        }

        if (progress > 100) progress = 100;
        totalProgress[kitab] = progress;
      });

      // Hitung Non Nadzam
      totalSetoran.forEach((kitab, jumlahSetoran) {
        double progress = 0;
        if (kitab == 'awamil') {
          progress = (jumlahSetoran / 100) * 100;
        } else if (kitab == 'jurumiyah') {
          progress = (jumlahSetoran / 25) * 100;
        }

        if (progress > 100) progress = 100;
        totalProgress[kitab] = progress;
      });

      final marhalahSantri = santri?['marhalah']?.toString() ?? '';

      totalProgress.forEach((kitab, progress) {
        // Filter Marhalah aktif santri
        if (marhalahSantri.contains('3')) {
          if (kitab != 'imrithi' && kitab != 'maqsud') return;
        } else if (marhalahSantri.contains('1')) {
          if (kitab != 'awamil') return;
        } else if (marhalahSantri.contains('2')) {
          if (kitab != 'jurumiyah') return;
        }

        progressKitab.add({
          'kitab': kitab,
          'progress': progress,
        });
      });

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error progress: $e');
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
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
        MaterialPageRoute(builder: (_) => const Login()),
        (route) => false,
      );
    }
  }

  // ================= CARD INFO GENERAL =================
  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.lime[300],
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI BUILDER =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.lime[400],
        title: const Text('Dashboard Wali Santri'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : santri == null
              ? const Center(child: Text('Data santri tidak ditemukan'))
              : RefreshIndicator(
                  onRefresh: fetchDataSantri,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ================= HEADER WELCOME =================
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.lime[400],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Selamat Datang', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(
                              widget.namaWali,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text('Monitoring Hafalan Santri', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ================= DATA PROFILE SANTRI =================
                      buildInfoCard(
                        icon: Icons.person,
                        title: 'Nama Santri',
                        value: santri!['nama_lengkap'] ?? '-',
                      ),
                      const SizedBox(height: 14),
                      buildInfoCard(
                        icon: Icons.class_,
                        title: 'Kelas',
                        value: santri!['kelas']?.toString() ?? '-',
                      ),
                      const SizedBox(height: 14),
                      buildInfoCard(
                        icon: Icons.menu_book,
                        title: 'Marhalah',
                        value: santri!['marhalah']?.toString() ?? '-',
                      ),
                      const SizedBox(height: 28),

                      // ================= SECTION PROGRESS HAFALAN =================
                      const Text(
                        'Progress Hafalan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),

                      ...progressKitab.map((item) {
                        final progress = item['progress'] as double;
                        final namaKitabRaw = item['kitab'].toString();
                        
                        final namaKitabFormatted = namaKitabRaw.isNotEmpty
                            ? '${namaKitabRaw[0].toUpperCase()}${namaKitabRaw.substring(1)}'
                            : '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    namaKitabFormatted,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text("${progress.toInt()}%"),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.lime,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 28),

                      // ================= MENU MONITORING =================
                      const Text(
                        'Menu Monitoring',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MonitoringHafalanPage(
                                      santriId: santri!['id'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.analytics, size: 42, color: Colors.lime[700]),
                                    const SizedBox(height: 12),
                                    const Text('Monitoring Hafalan', textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RiwayatKhatamanPage(
                                      santriId: santri!['id'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.fact_check, size: 42, color: Colors.lime[700]),
                                    const SizedBox(height: 12),
                                    const Text('Riwayat Khataman', textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Chat Button
                      InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPageWali(
                                waliId: widget.waliId,
                                namaWali: widget.namaWali,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.chat, size: 42, color: Colors.lime[700]),
                              const SizedBox(height: 12),
                              const Text('Chat Pembimbing', textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}