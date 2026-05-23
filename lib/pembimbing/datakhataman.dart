import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataKhatamanPage extends StatefulWidget {
  final String marhalah;

  const DataKhatamanPage({
    super.key,
    required this.marhalah,
  });

  @override
  State<DataKhatamanPage> createState() =>
      _DataKhatamanPageState();
}

class _DataKhatamanPageState
    extends State<DataKhatamanPage> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  List<Map<String, dynamic>>
      dataKhataman = [];

  @override
  void initState() {
    super.initState();

    fetchDataKhataman();
  }

  // ================= FETCH DATA =================
  Future<void>
      fetchDataKhataman() async {

    setState(() {
      loading = true;
    });

    try {

      // ================= AMBIL DATA KHATAMAN =================
      final data = await supabase
          .from('setoran_khataman')
          .select()
          .order(
            'tanggal_pengajuan',
            ascending: false,
          );

      List<Map<String, dynamic>>
          hasil = [];

      // ================= FILTER BERDASARKAN MARHALAH =================
      for (var item in data) {

        final santriId =
            item['santri_id'];

        final santriData =
            await supabase
                .from('santri')
                .select(
                    'nama_lengkap, kelas, marhalah')
                .eq('id', santriId)
                .maybeSingle();

        // ================= CEK MARHALAH =================
        if (santriData != null &&
            santriData['marhalah'] ==
                widget.marhalah) {

          hasil.add({

            ...item,

            'santri': santriData,
          });
        }
      }

      if (!mounted) return;

      setState(() {

        dataKhataman = hasil;

        loading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Gagal mengambil data: $e",
          ),
        ),
      );
    }
  }

  // ================= WARNA STATUS =================
  Color getStatusColor(
      String status) {

    switch (status.toLowerCase()) {

      case 'pending':
        return Colors.orange;

      case 'approve':
        return Colors.green;

      case 'ditolak':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ================= FORMAT TANGGAL =================
  String formatTanggal(
      dynamic tanggal) {

    if (tanggal == null) {
      return "-";
    }

    try {

      final tgl =
          DateTime.parse(
              tanggal.toString());

      return
          "${tgl.day}/${tgl.month}/${tgl.year}";

    } catch (e) {

      return "-";
    }
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
          "Data Setoran Khataman",
        ),
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : dataKhataman.isEmpty

              ? const Center(
                  child: Text(
                    "Belum ada pengajuan khataman",
                  ),
                )

              : RefreshIndicator(

                  onRefresh:
                      fetchDataKhataman,

                  child: ListView.builder(

                    padding:
                        const EdgeInsets.all(
                            16),

                    itemCount:
                        dataKhataman.length,

                    itemBuilder:
                        (context, i) {

                      final item =
                          dataKhataman[i];

                      final santri =
                          item['santri'] ?? {};

                      return Container(

                        margin:
                            const EdgeInsets.only(
                                bottom: 16),

                        padding:
                            const EdgeInsets.all(
                                18),

                        decoration:
                            BoxDecoration(

                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                                  20),

                          boxShadow: [

                            BoxShadow(

                              color:
                                  Colors.black
                                      .withOpacity(
                                          0.05),

                              blurRadius: 8,

                              offset:
                                  const Offset(
                                      0, 4),
                            ),
                          ],
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            // ================= HEADER =================
                            Row(

                              children: [

                                CircleAvatar(

                                  backgroundColor:
                                      Colors
                                          .lime[300],

                                  child: const Icon(
                                    Icons.person,
                                    color:
                                        Colors.black,
                                  ),
                                ),

                                const SizedBox(
                                    width: 12),

                                Expanded(

                                  child: Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(

                                        santri[
                                                'nama_lengkap'] ??
                                            '-',

                                        style:
                                            const TextStyle(

                                          fontWeight:
                                              FontWeight
                                                  .bold,

                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 2),

                                      Text(
                                        santri[
                                                'kelas'] ??
                                            '-',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 18),

                            // ================= KITAB =================
                            Row(

                              children: [

                                const Icon(
                                  Icons.menu_book,
                                  size: 20,
                                ),

                                const SizedBox(
                                    width: 8),

                                Expanded(

                                  child: Text(

                                    item['kitab']
                                            ?.toString()
                                            .toUpperCase() ??
                                        '-',

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 12),

                            // ================= STATUS =================
                            Row(

                              children: [

                                const Text(
                                  "Status : ",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                Container(

                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        getStatusColor(
                                      item['status'] ??
                                          'pending',
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                            20),
                                  ),

                                  child: Text(

                                    item['status'] ??
                                        '-',

                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 12),

                            // ================= TANGGAL PENGAJUAN =================
                            Text(
                              "Tanggal Pengajuan : ${formatTanggal(item['tanggal_pengajuan'])}",
                            ),

                            const SizedBox(
                                height: 8),

                            // ================= TANGGAL SETORAN =================
                            if (item[
                                    'tanggal_setoran'] !=
                                null)

                              Text(
                                "Tanggal Setoran : ${formatTanggal(item['tanggal_setoran'])}",
                              ),

                            // ================= JADWAL =================
                            if (item[
                                    'jadwal_setoran'] !=
                                null) ...[

                              const SizedBox(
                                  height: 8),

                              Text(
                                "Jadwal Setoran : ${formatTanggal(item['jadwal_setoran'])}",
                              ),
                            ],

                            // ================= CATATAN ADMIN =================
                            if (item[
                                    'catatan_admin'] !=
                                null &&
                                item['catatan_admin']
                                    .toString()
                                    .isNotEmpty) ...[

                              const SizedBox(
                                  height: 10),

                              Container(

                                width:
                                    double.infinity,

                                padding:
                                    const EdgeInsets
                                        .all(12),

                                decoration:
                                    BoxDecoration(

                                  color:
                                      Colors.grey[
                                          100],

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              12),
                                ),

                                child: Text(
                                  "Catatan Admin : ${item['catatan_admin']}",
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}