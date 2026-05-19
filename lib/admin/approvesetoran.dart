import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApproveKhatamanPage extends StatefulWidget {
  const ApproveKhatamanPage({super.key});

  @override
  State<ApproveKhatamanPage> createState() =>
      _ApproveKhatamanPageState();
}

class _ApproveKhatamanPageState
    extends State<ApproveKhatamanPage> {

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

      final response = await supabase
          .from('setoran_khataman')
          .select('''
            id,
            kitab,
            status,
            catatan_admin,
            tanggal_pengajuan,
            tanggal_setoran,
            santri (
              nama_lengkap,
              kelas,
              marhalah
            )
          ''')
          .order(
            'tanggal_pengajuan',
            ascending: false,
          );

      if (!mounted) return;

      setState(() {

        dataKhataman =
            List<Map<String,
                dynamic>>.from(response);

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
            'Gagal mengambil data: $e',
          ),
        ),
      );
    }
  }

  // ================= APPROVE =================
  Future<void> approveKhataman(
    int id,
  ) async {

    try {

      await supabase
          .from('setoran_khataman')
          .update({

        'status': 'disetujui',

        'tanggal_approve':
            DateTime.now()
                .toIso8601String(),

      }).eq('id', id);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Setoran berhasil disetujui',
          ),
        ),
      );

      fetchDataKhataman();

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal approve: $e',
          ),
        ),
      );
    }
  }

  // ================= TOLAK =================
  Future<void> tolakKhataman(
    int id,
  ) async {

    final TextEditingController
        catatanController =
            TextEditingController();

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            'Tolak Setoran',
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              const Text(
                'Masukkan alasan atau catatan admin',
              ),

              const SizedBox(
                  height: 16),

              TextField(

                controller:
                    catatanController,

                maxLines: 3,

                decoration:
                    InputDecoration(

                  hintText:
                      'Contoh: Hafalan belum lengkap',

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            12),
                  ),
                ),
              ),
            ],
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                    context);
              },

              child:
                  const Text(
                'Batal',
              ),
            ),

            ElevatedButton(

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),

              onPressed:
                  () async {

                try {

                  await supabase
                      .from(
                          'setoran_khataman')
                      .update({

                    'status':
                        'ditolak',

                    'catatan_admin':
                        catatanController
                            .text,

                    'tanggal_approve':
                        DateTime.now()
                            .toIso8601String(),

                  }).eq(
                    'id',
                    id,
                  );

                  Navigator.pop(
                      context);

                  ScaffoldMessenger.of(
                          this.context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Setoran ditolak',
                      ),
                    ),
                  );

                  fetchDataKhataman();

                } catch (e) {

                  ScaffoldMessenger.of(
                          this.context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        'Gagal menolak: $e',
                      ),
                    ),
                  );
                }
              },

              child:
                  const Text(
                'Tolak',
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= WARNA STATUS =================
  Color getStatusColor(
      String status) {

    switch (status) {

      case 'disetujui':
        return Colors.green;

      case 'ditolak':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[200],

      appBar: AppBar(

        title: const Text(
          'Approve Khataman',
        ),

        backgroundColor:
            Colors.lime[400],
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
                      fetchDataKhataman,

                  child: ListView.builder(

                    padding:
                        const EdgeInsets.all(
                            16),

                    itemCount:
                        dataKhataman.length,

                    itemBuilder:
                        (context, index) {

                      final item =
                          dataKhataman[
                              index];

                      final santri =
                          item['santri'];

                      final status =
                          item['status'] ??
                              'pending';

                      return Container(

                        margin:
                            const EdgeInsets.only(
                                bottom: 16),

                        padding:
                            const EdgeInsets.all(
                                16),

                        decoration:
                            BoxDecoration(

                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                                  18),

                          boxShadow: [

                            BoxShadow(

                              color:
                                  Colors.black12,

                              blurRadius:
                                  6,

                              offset:
                                  const Offset(
                                      0,
                                      3),
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

                                  child:
                                      const Icon(
                                    Icons
                                        .menu_book,

                                    color: Colors.black,
                                  ),
                                ),

                                const SizedBox(
                                    width: 12),

                                Expanded(

                                  child:
                                      Column(

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

                                          fontSize:
                                              16,

                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      Text(
                                        '${santri['kelas']} • ${santri['marhalah']}',
                                      ),
                                    ],
                                  ),
                                ),

                                Container(

                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal:
                                        12,
                                    vertical:
                                        6,
                                  ),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        getStatusColor(
                                      status,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                            20),
                                  ),

                                  child: Text(

                                    status
                                        .toUpperCase(),

                                    style:
                                        const TextStyle(

                                      color:
                                          Colors.white,

                                      fontWeight:
                                          FontWeight.bold,

                                      fontSize:
                                          12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 18),

                            // ================= DETAIL =================
                            buildItemDetail(
                              'Kitab',
                              item['kitab'] ??
                                  '-',
                            ),

                            buildItemDetail(
                              'Tanggal Pengajuan',

                              DateFormat(
                                      'dd MMM yyyy')
                                  .format(
                                DateTime.parse(
                                  item[
                                      'tanggal_pengajuan'],
                                ),
                              ),
                            ),

                            if (item[
                                    'tanggal_setoran'] !=
                                null)

                              buildItemDetail(

                                'Tanggal Khatam',

                                DateFormat(
                                        'dd MMM yyyy')
                                    .format(
                                  DateTime.parse(
                                    item[
                                        'tanggal_setoran'],
                                  ),
                                ),
                              ),

                            if (item[
                                        'catatan_admin'] !=
                                    null &&
                                item[
                                        'catatan_admin']
                                    .toString()
                                    .isNotEmpty)

                              Container(

                                margin:
                                    const EdgeInsets.only(
                                        top: 12),

                                padding:
                                    const EdgeInsets.all(
                                        12),

                                decoration:
                                    BoxDecoration(

                                  color:
                                      Colors.red[50],

                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                ),

                                child: Row(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    const Icon(
                                      Icons.info,
                                      color:
                                          Colors.red,
                                    ),

                                    const SizedBox(
                                        width:
                                            10),

                                    Expanded(

                                      child:
                                          Text(

                                        item[
                                            'catatan_admin'],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(
                                height: 20),

                            // ================= BUTTON =================
                            if (status ==
                                'pending')

                              Row(

                                children: [

                                  Expanded(

                                    child:
                                        ElevatedButton.icon(

                                      style:
                                          ElevatedButton.styleFrom(

                                        backgroundColor:
                                            Colors.green,
                                      ),

                                      onPressed:
                                          () {

                                        approveKhataman(
                                          item[
                                              'id'],
                                        );
                                      },

                                      icon:
                                          const Icon(
                                        Icons
                                            .check,
                                        color:
                                            Colors.white,
                                      ),

                                      label:
                                          const Text(
                                        'Approve',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      width:
                                          12),

                                  Expanded(

                                    child:
                                        ElevatedButton.icon(

                                      style:
                                          ElevatedButton.styleFrom(

                                        backgroundColor:
                                            Colors.red,
                                      ),

                                      onPressed:
                                          () {

                                        tolakKhataman(
                                          item[
                                              'id'],
                                        );
                                      },

                                      icon:
                                          const Icon(
                                        Icons
                                            .close,
                                        color:
                                            Colors.white,
                                      ),

                                      label:
                                          const Text(
                                        'Tolak',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // ================= ITEM DETAIL =================
  Widget buildItemDetail(
    String title,
    String value,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
              bottom: 10),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(

            width: 140,

            child: Text(

              title,

              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}