import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatKhatamanPage
    extends StatefulWidget {

  final int santriId;

  const RiwayatKhatamanPage({
    super.key,
    required this.santriId,
  });

  @override
  State<RiwayatKhatamanPage>
      createState() =>
          _RiwayatKhatamanPageState();
}

class _RiwayatKhatamanPageState
    extends State<
        RiwayatKhatamanPage> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  List<Map<String, dynamic>>
      dataKhataman = [];

  @override
  void initState() {
    super.initState();

    fetchRiwayatKhataman();
  }

  // ================= FETCH DATA =================
  Future<void>
      fetchRiwayatKhataman() async {

    setState(() {
      loading = true;
    });

    try {

      final data = await supabase

          .from('setoran_khataman')

          .select()

          .eq(
            'santri_id',
            widget.santriId,
          )

          .order(
            'tanggal_pengajuan',
            ascending: false,
          );

      if (!mounted) return;

      setState(() {

        dataKhataman =
            List<Map<String,
                dynamic>>.from(data);

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
            'Gagal mengambil data khataman: $e',
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

  // ================= WARNA JADWAL =================
  Color getJadwalColor(
      String status) {

    switch (status.toLowerCase()) {

      case 'sudah dijadwalkan':
        return Colors.green;

      case 'menunggu jadwal':
        return Colors.orange;

      default:
        return Colors.grey;
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
          'Riwayat Khataman',
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
                    'Belum ada pengajuan khataman',
                  ),
                )

              : RefreshIndicator(

                  onRefresh:
                      fetchRiwayatKhataman,

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

                      DateTime? tanggalPengajuan;

                      try {

                        tanggalPengajuan =
                            DateTime.parse(
                          item[
                              'tanggal_pengajuan'],
                        );

                      } catch (_) {}

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
                                  22),
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

                                  radius: 24,

                                  backgroundColor:
                                      Colors
                                          .lime[300],

                                  child: const Icon(

                                    Icons
                                        .menu_book,

                                    color:
                                        Colors.black,
                                  ),
                                ),

                                const SizedBox(
                                    width: 14),

                                Expanded(

                                  child: Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(

                                        item['kitab']
                                            .toString()
                                            .toUpperCase(),

                                        style:
                                            const TextStyle(

                                          fontSize:
                                              17,

                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              4),

                                      Text(

                                        tanggalPengajuan ==
                                                null
                                            ? '-'
                                            : "Pengajuan: ${tanggalPengajuan.day}/${tanggalPengajuan.month}/${tanggalPengajuan.year}",

                                        style:
                                            const TextStyle(

                                          color:
                                              Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 20),

                            // ================= STATUS =================
                            Row(

                              children: [

                                const Text(

                                  'Status: ',

                                  style: TextStyle(

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                Container(

                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        getStatusColor(
                                      item['status'] ??
                                          '',
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
                                height: 16),

                            // ================= JADWAL =================
                            Container(

                              width:
                                  double.infinity,

                              padding:
                                  const EdgeInsets.all(
                                      16),

                              decoration:
                                  BoxDecoration(

                                color:
                                    Colors.grey[
                                        100],

                                borderRadius:
                                    BorderRadius.circular(
                                        18),
                              ),

                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  const Text(

                                    'Informasi Jadwal',

                                    style: TextStyle(

                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      fontSize:
                                          15,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          12),

                                  Row(

                                    children: [

                                      const Icon(
                                        Icons
                                            .calendar_month,
                                        size:
                                            20,
                                      ),

                                      const SizedBox(
                                          width:
                                              8),

                                      Expanded(

                                        child: Text(

                                          item['jadwal_setoran'] ==
                                                  null
                                              ? 'Belum ada jadwal setoran'
                                              : "Jadwal: ${item['jadwal_setoran']}",
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                      height:
                                          12),

                                  Row(

                                    children: [

                                      const Text(

                                        'Status Jadwal: ',

                                        style:
                                            TextStyle(

                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      Container(

                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal:
                                              12,
                                          vertical:
                                              5,
                                        ),

                                        decoration:
                                            BoxDecoration(

                                          color:
                                              getJadwalColor(

                                            item['status_jadwal'] ??
                                                '',
                                          ),

                                          borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                        ),

                                        child:
                                            Text(

                                          item['status_jadwal'] ??
                                              'Menunggu Jadwal',

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
                                ],
                              ),
                            ),

                            const SizedBox(
                                height: 16),

                            // ================= CATATAN ADMIN =================
                            if (item[
                                    'catatan_admin'] !=
                                null)

                              Container(

                                width:
                                    double.infinity,

                                padding:
                                    const EdgeInsets.all(
                                        16),

                                decoration:
                                    BoxDecoration(

                                  color:
                                      Colors.orange[
                                          50],

                                  borderRadius:
                                      BorderRadius.circular(
                                          18),
                                ),

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    const Text(

                                      'Catatan Admin',

                                      style:
                                          TextStyle(

                                        fontWeight:
                                            FontWeight
                                                .bold,

                                        fontSize:
                                            15,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                            10),

                                    Text(
                                      item[
                                          'catatan_admin'],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}