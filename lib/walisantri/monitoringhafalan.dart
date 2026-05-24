import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonitoringHafalanPage
    extends StatefulWidget {

  final int santriId;

  const MonitoringHafalanPage({
    super.key,
    required this.santriId,
  });

  @override
  State<MonitoringHafalanPage>
      createState() =>
          _MonitoringHafalanPageState();
}

class _MonitoringHafalanPageState
    extends State<
        MonitoringHafalanPage> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  List<Map<String, dynamic>>
      dataHafalan = [];

  @override
  void initState() {
    super.initState();

    fetchHafalan();
  }

  // ================= FETCH DATA =================
  Future<void> fetchHafalan() async {

    setState(() {
      loading = true;
    });

    try {

      final data = await supabase

          .from('hafalan_santri')

          .select()

          .eq(
            'santri_id',
            widget.santriId,
          )

          .order(
            'tanggal',
            ascending: false,
          );

      if (!mounted) return;

      setState(() {

        dataHafalan =
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
            'Gagal mengambil data hafalan: $e',
          ),
        ),
      );
    }
  }

  // ================= WARNA STATUS =================
  Color getStatusColor(
      String status) {

    switch (status.toLowerCase()) {

      case 'lancar':
        return Colors.green;

      case 'kurang lancar':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  // ================= ICON KITAB =================
  IconData getKitabIcon(
      String kitab) {

    switch (kitab.toLowerCase()) {

      case 'awamil':
        return Icons.menu_book;

      case 'jurumiyah':
        return Icons.auto_stories;

      case 'imrithi':
        return Icons.book;

      case 'maqsud':
        return Icons.library_books;

      case 'alfiyah':
        return Icons.collections_bookmark;

      default:
        return Icons.book_outlined;
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
          'Monitoring Hafalan',
        ),
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : dataHafalan.isEmpty

              ? const Center(

                  child: Text(
                    'Belum ada data hafalan',
                  ),
                )

              : RefreshIndicator(

                  onRefresh:
                      fetchHafalan,

                  child: ListView.builder(

                    padding:
                        const EdgeInsets.all(
                            16),

                    itemCount:
                        dataHafalan.length,

                    itemBuilder:
                        (context, i) {

                      final item =
                          dataHafalan[i];

                      DateTime? tanggal;

                      try {

                        tanggal =
                            DateTime.parse(
                          item['tanggal'],
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

                                  child: Icon(

                                    getKitabIcon(
                                      item['kitab'],
                                    ),

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
                                              16,

                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              4),

                                      Text(

                                        tanggal ==
                                                null
                                            ? '-'
                                            : "${tanggal.day}/${tanggal.month}/${tanggal.year}",

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
                                height: 18),

                            // ================= HAFALAN =================
                            const Text(

                              'Hafalan:',

                              style: TextStyle(

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                                height: 6),

                            Text(

                              item['bagian'] ??
                                  '-',

                              style:
                                  const TextStyle(
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(
                                height: 18),

                            // ================= JUMLAH BAIT =================
                            Row(

                              children: [

                                Expanded(

                                  child: Container(

                                    padding:
                                        const EdgeInsets.all(
                                            14),

                                    decoration:
                                        BoxDecoration(

                                      color:
                                          Colors.grey[
                                              100],

                                      borderRadius:
                                          BorderRadius.circular(
                                              16),
                                    ),

                                    child: Column(

                                      children: [

                                        const Text(

                                          'Jumlah Hafalan',

                                          style:
                                              TextStyle(
                                            fontSize:
                                                13,
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                6),

                                        Text(

                                          item['jumlah_bait'] ==
                                                  null
                                              ? '-'
                                              : "${item['jumlah_bait']} bait",

                                          style:
                                              const TextStyle(

                                            fontWeight:
                                                FontWeight
                                                    .bold,

                                            fontSize:
                                                16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    width: 14),

                                Expanded(

                                  child: Container(

                                    padding:
                                        const EdgeInsets.all(
                                            14),

                                    decoration:
                                        BoxDecoration(

                                      color:
                                          getStatusColor(
                                        item['status'] ??
                                            '',
                                      ).withOpacity(
                                              0.15),

                                      borderRadius:
                                          BorderRadius.circular(
                                              16),
                                    ),

                                    child: Column(

                                      children: [

                                        const Text(

                                          'Status',

                                          style:
                                              TextStyle(
                                            fontSize:
                                                13,
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                6),

                                        Text(

                                          item['status'] ??
                                              '-',

                                          style:
                                              TextStyle(

                                            fontWeight:
                                                FontWeight
                                                    .bold,

                                            color:
                                                getStatusColor(
                                              item['status'] ??
                                                  '',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 16),

                            // ================= PEMBIMBING =================
                            Row(

                              children: [

                                const Icon(
                                  Icons.person,
                                  size: 18,
                                ),

                                const SizedBox(
                                    width: 8),

                                Expanded(

                                  child: Text(

                                    "Pembimbing: ${item['pembimbing_input'] ?? '-'}",

                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
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
}