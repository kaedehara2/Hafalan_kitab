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

      final data = await supabase
          .from('setoran_khataman')
          .select('''
            id,
            kitab,
            status,
            tanggal_pengajuan,
            tanggal_setoran,
            status_jadwal,
            jadwal_setoran,
            santri (
              nama_lengkap,
              kelas,
              marhalah
            )
          ''')
          .eq(
            'santri.marhalah',
            widget.marhalah,
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
                          item['santri'];

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
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

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
                                            'nama_lengkap'],

                                        style:
                                            const TextStyle(

                                          fontWeight:
                                              FontWeight
                                                  .bold,

                                          fontSize: 16,
                                        ),
                                      ),

                                      Text(
                                        santri[
                                            'kelas'],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 18),

                            Row(

                              children: [

                                const Icon(
                                  Icons.menu_book,
                                  size: 20,
                                ),

                                const SizedBox(
                                    width: 8),

                                Text(
                                  item['kitab'],
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 10),

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
                                      item['status'],
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                            20),
                                  ),

                                  child: Text(

                                    item['status'],

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
                                height: 10),

                            if (item[
                                    'jadwal_setoran'] !=
                                null)

                              Text(
                                "Jadwal Setoran : ${item['jadwal_setoran']}",
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