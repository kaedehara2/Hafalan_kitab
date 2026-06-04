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
  State<DashboardWaliPage> createState() =>
      _DashboardWaliPageState();
}

class _DashboardWaliPageState
    extends State<DashboardWaliPage> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  Map<String, dynamic>? santri;

  List<Map<String, dynamic>>
      progressKitab = [];

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

          .eq(
            'wali_id',
            int.parse(widget.waliId),
          )

          .maybeSingle();

      if (data == null) {

        setState(() {
          loading = false;
        });

        return;
      }

      santri = data;

      await loadProgressKitab(
        santri!['id'],
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            'Gagal mengambil data: $e',
          ),
        ),
      );
    }
  }

 // ================= LOAD PROGRESS =================
Future<void> loadProgressKitab(
    int santriId) async {

  progressKitab.clear();

  try {

    final hafalan = await supabase

        .from('hafalan_santri')

        .select()

        .eq(
          'santri_id',
          santriId,
        );

    // ================= PENAMPUNG =================
    Map<String, double>
        totalProgress = {};

    // ================= NADZAM =================
    Map<String, int>
        totalBait = {};

    // ================= NON NADZAM =================
    Map<String, int>
        totalSetoran = {};

    for (var item in hafalan) {

      final kitab =
          item['kitab']
              .toString()
              .toLowerCase();

      // ================= KITAB NADZAM =================
      if (kitab == 'imrithi' ||
          kitab == 'maqsud' ||
          kitab == 'alfiyah') {

        final jumlahBait =
            int.tryParse(
                  item['jumlah_bait']
                          ?.toString() ??
                      '0',
                ) ??
                0;

        totalBait[kitab] =
            (totalBait[kitab] ?? 0) +
                jumlahBait;
      }

      // ================= KITAB NON NADZAM =================
      else {

        totalSetoran[kitab] =
            (totalSetoran[kitab] ?? 0) +
                1;
      }
    }

    // ================= HITUNG NADZAM =================
    totalBait.forEach(
      (kitab, jumlah) {

        double progress = 0;

        if (kitab == 'imrithi') {

          progress =
              (jumlah / 254) * 100;
        }

        else if (kitab == 'maqsud') {

          progress =
              (jumlah / 113) * 100;
        }

        else if (kitab == 'alfiyah') {

          progress =
              (jumlah / 1002) * 100;
        }

        if (progress > 100) {
          progress = 100;
        }

        totalProgress[kitab] =
            progress;
      },
    );

    // ================= HITUNG NON NADZAM =================
    totalSetoran.forEach(
      (kitab, jumlahSetoran) {

        double progress = 0;

        if (kitab == 'awamil') {

          progress =
              (jumlahSetoran / 100) *
                  100;
        }

        else if (kitab ==
            'jurumiyah') {

          progress =
              (jumlahSetoran / 25) *
                  100;
        }

        if (progress > 100) {
          progress = 100;
        }

        totalProgress[kitab] =
            progress;
      },
    );

    // ================= MASUK LIST =================
    totalProgress.forEach(
      (kitab, progress) {

        progressKitab.add({

          'kitab': kitab,

          'progress': progress,
        });
      },
    );

    // ================= REFRESH UI =================
    if (mounted) {
      setState(() {});
    }

  } catch (e) {

    debugPrint(
      'Error progress: $e',
    );
  }
}

  // ================= CARD =================
  Widget buildInfoCard({

    required IconData icon,
    required String title,
    required String value,

  }) {

    return Container(

      padding:
          const EdgeInsets.all(
              18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                20),
      ),

      child: Row(

        children: [

          CircleAvatar(

            radius: 24,

            backgroundColor:
                Colors.lime[300],

            child: Icon(
              icon,
              color: Colors.black,
            ),
          ),

          const SizedBox(
              width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  title,

                  style:
                      const TextStyle(

                    fontSize: 14,

                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                    height: 4),

                Text(

                  value,

                  style:
                      const TextStyle(

                    fontSize: 16,

                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[200],

      appBar: AppBar(

        backgroundColor:
            Colors.lime[400],

        title: const Text(
          'Dashboard Wali Santri',
        ),

        actions: [

          IconButton(

            onPressed: logout,

            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : santri == null

              ? const Center(

                  child: Text(
                    'Data santri tidak ditemukan',
                  ),
                )

              : RefreshIndicator(

                  onRefresh:
                      fetchDataSantri,

                  child: ListView(

                    padding:
                        const EdgeInsets.all(
                            16),

                    children: [

                      // ================= HEADER =================
                      Container(

                        padding:
                            const EdgeInsets.all(
                                20),

                        decoration:
                            BoxDecoration(

                          color:
                              Colors.lime[400],

                          borderRadius:
                              BorderRadius.circular(
                                  24),
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            const Text(

                              'Selamat Datang',

                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                                height: 6),

                            Text(

                              widget.namaWali,

                              style:
                                  const TextStyle(

                                fontSize: 24,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                                height: 6),

                            const Text(

                              'Monitoring Hafalan Santri',

                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                          height: 24),

                      // ================= DATA SANTRI =================
                      buildInfoCard(

                        icon:
                            Icons.person,

                        title:
                            'Nama Santri',

                        value: santri![
                            'nama_lengkap'],
                      ),

                      const SizedBox(
                          height: 14),

                      buildInfoCard(

                        icon:
                            Icons.class_,

                        title: 'Kelas',

                        value:
                            santri!['kelas'],
                      ),

                      const SizedBox(
                          height: 14),

                      buildInfoCard(

                        icon:
                            Icons.menu_book,

                        title:
                            'Marhalah',

                        value: santri![
                            'marhalah'],
                      ),

                      const SizedBox(
                          height: 28),

                      // ================= PROGRESS =================
                      const Text(

                        'Progress Hafalan',

                        style: TextStyle(

                          fontSize: 18,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 14),

                      ...progressKitab.map(

                        (item) {

                          final progress =
                              item[
                                  'progress'];

                          return Container(

                            margin:
                                const EdgeInsets.only(
                                    bottom:
                                        14),

                            padding:
                                const EdgeInsets.all(
                                    16),

                            decoration:
                                BoxDecoration(

                              color:
                                  Colors.white,

                              borderRadius:
                                  BorderRadius.circular(
                                      20),
                            ),

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Row(

                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,

                                  children: [

                                    Text(

                                      item[
                                          'kitab'],

                                      style:
                                          const TextStyle(

                                        fontWeight:
                                            FontWeight
                                                .bold,

                                        fontSize:
                                            16,
                                      ),
                                    ),

                                    Text(
                                      "${progress.toInt()}%",
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height:
                                        10),

                                ClipRRect(

                                  borderRadius:
                                      BorderRadius.circular(
                                          20),

                                  child:
                                      LinearProgressIndicator(

                                    value:
                                        progress / 100,

                                    minHeight:
                                        10,

                                    backgroundColor:
                                        Colors.grey[
                                            300],

                                    color:
                                        Colors
                                            .lime,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                          height: 28),

                      // ================= MENU =================
                      const Text(

                        'Menu Monitoring',

                        style: TextStyle(

                          fontSize: 18,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 16),

                      Row(

                        children: [

                          Expanded(

                            child: InkWell(

                              borderRadius:
                                  BorderRadius.circular(
                                      22),

                              onTap: () {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) =>
                                        MonitoringHafalanPage(

                                      santriId:
                                          santri![
                                              'id'],
                                    ),
                                  ),
                                );
                              },

                              child: Container(

                                padding:
                                    const EdgeInsets.all(
                                        20),

                                decoration:
                                    BoxDecoration(

                                  color:
                                      Colors.white,

                                  borderRadius:
                                      BorderRadius.circular(
                                          22),
                                ),

                                child:
                                    const Column(

                                  children: [

                                    Icon(

                                      Icons
                                          .analytics,

                                      size:
                                          42,
                                    ),

                                    SizedBox(
                                        height:
                                            12),

                                    Text(
                                      'Monitoring Hafalan',
                                      textAlign:
                                          TextAlign
                                              .center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                              width: 16),

                          Expanded(

                            child: InkWell(

                              borderRadius:
                                  BorderRadius.circular(
                                      22),

                              onTap: () {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) =>
                                        RiwayatKhatamanPage(

                                      santriId:
                                          santri![
                                              'id'],
                                    ),
                                  ),
                                );
                              },

                              child: Container(

                                padding:
                                    const EdgeInsets.all(
                                        20),

                                decoration:
                                    BoxDecoration(

                                  color:
                                      Colors.white,

                                  borderRadius:
                                      BorderRadius.circular(
                                          22),
                                ),

                                child:
                                    const Column(

                                  children: [

                                    Icon(

                                      Icons
                                          .fact_check,

                                      size:
                                          42,
                                    ),

                                    SizedBox(
                                        height:
                                            12),

                                    Text(
                                      'Riwayat Khataman',
                                      textAlign:
                                          TextAlign
                                              .center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

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

    child: const Column(
      children: [

        Icon(
          Icons.chat,
          size: 42,
        ),

        SizedBox(height: 12),

        Text(
          'Chat Pembimbing',
          textAlign: TextAlign.center,
        ),
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