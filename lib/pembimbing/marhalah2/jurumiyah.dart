import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JurumiyahPage extends StatefulWidget {

  final String username;

  const JurumiyahPage({
    super.key,
    required this.username,
  });

  @override
  State<JurumiyahPage> createState() =>
      _JurumiyahPageState();
}

class _JurumiyahPageState
    extends State<JurumiyahPage> {

  final supabase = Supabase.instance.client;

  bool loading = true;
  bool loadingRiwayat = false;

  List<Map<String, dynamic>> santriList = [];

  Map<String, dynamic>? selectedSantri;

  List<Map<String, dynamic>>
      riwayatHafalan = [];

  String? penilaian;

  final TextEditingController
      hafalanController =
      TextEditingController();

  final int totalTarget = 26;

  @override
  void initState() {
    super.initState();
    fetchSantri();
  }

  // ================= FETCH SANTRI =================
  Future<void> fetchSantri() async {

    setState(() => loading = true);

    try {

      final data = await supabase
          .from('santri')
          .select(
              'id, nama_lengkap, kelas')
          .eq('marhalah', 'Marhalah 2')
          .order('nama_lengkap');

      if (!mounted) return;

      setState(() {

        santriList =
            List<Map<String, dynamic>>
                .from(data);

        loading = false;
      });

    } catch (e) {

      setState(() => loading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
              "Gagal mengambil data santri: $e"),
        ),
      );
    }
  }

  // ================= FETCH RIWAYAT =================
  Future<void> fetchRiwayat(
      int santriId) async {

    setState(() => loadingRiwayat = true);

    try {

      final data = await supabase
          .from('hafalan_santri')
          .select()
          .eq('santri_id', santriId)
          .eq('kitab', 'jurumiyah')
          .order('tanggal',
              ascending: false);

      if (!mounted) return;

      setState(() {

        riwayatHafalan =
            List<Map<String, dynamic>>
                .from(data);

        loadingRiwayat = false;
      });

    } catch (e) {

      setState(
          () => loadingRiwayat = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
              "Gagal mengambil riwayat: $e"),
        ),
      );
    }
  }

  // ================= HITUNG PROGRESS =================
  Future<double> getProgress(
      int santriId) async {

    try {

      final data = await supabase
          .from('hafalan_santri')
          .select('id')
          .eq('santri_id', santriId)
          .eq('kitab', 'jurumiyah');

      double progress =
          (data.length / totalTarget) *
              100;

      if (progress > 100) {
        progress = 100;
      }

      return progress;

    } catch (e) {

      return 0;
    }
  }

  // ================= CEK KHATAMAN =================
  Future<void> cekDanKirimKhataman(
      int santriId) async {

    try {

      final progress =
          await getProgress(santriId);

      if (progress >= 100) {

        final cekData = await supabase
            .from('setoran_khataman')
            .select()
            .eq('santri_id', santriId)
            .eq('kitab', 'jurumiyah');

        if (cekData.isEmpty) {

          await supabase
              .from('setoran_khataman')
              .insert({

            'santri_id': santriId,
            'kitab': 'jurumiyah',
            'status': 'pending',
          });

          if (!mounted) return;

          ScaffoldMessenger.of(context)
              .showSnackBar(

            const SnackBar(

              backgroundColor:
                  Colors.green,

              content: Text(
                "Santri berhasil masuk setoran khataman",
              ),
            ),
          );
        }
      }

    } catch (e) {

      debugPrint(
          "ERROR KHATAMAN : $e");
    }
  }

  // ================= INSERT HAFALAN =================
  Future<void> insertHafalan(
      int santriId) async {

    if (penilaian == null ||
        hafalanController.text.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text("Lengkapi data hafalan"),
        ),
      );

      return;
    }

    try {

      await supabase
          .from('hafalan_santri')
          .insert({

        'santri_id': santriId,

        'kitab': 'jurumiyah',

        'bagian':
            hafalanController.text,

        'status': penilaian,

        'pembimbing_input':
            widget.username,

        'is_setoran_cadangan':
            false,
      });

      await fetchRiwayat(santriId);

      await fetchSantri();

      await cekDanKirimKhataman(
          santriId);

      if (!mounted) return;

      setState(() {

        penilaian = null;

        hafalanController.clear();
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
              "Hafalan berhasil disimpan"),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
              "Gagal menyimpan hafalan: $e"),
        ),
      );
    }
  }

  // ================= DELETE =================
  Future<void> deleteHafalan({

    required int hafalanId,
    required int santriId,

  }) async {

    try {

      await supabase
          .from('hafalan_santri')
          .delete()
          .eq('id', hafalanId);

      await fetchRiwayat(santriId);

      await fetchSantri();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
              "Catatan hafalan berhasil dihapus"),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
              "Gagal menghapus hafalan: $e"),
        ),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor:
            Colors.lime[400],

        title: const Text(
          "Kitab Jurumiyah",
        ),

        leading: selectedSantri != null
            ? IconButton(

                icon: const Icon(
                    Icons.arrow_back),

                onPressed: () {

                  setState(() {

                    selectedSantri =
                        null;

                    riwayatHafalan.clear();
                  });
                },
              )
            : null,
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : selectedSantri == null

              ? buildListSantri()

              : buildCatatanHafalan(),
    );
  }

  // ================= LIST SANTRI =================
  Widget buildListSantri() {

    return Padding(

      padding:
          const EdgeInsets.all(12),

      child: GridView.builder(

        itemCount: santriList.length,

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount: 2,

          childAspectRatio: 2.5,

          crossAxisSpacing: 10,

          mainAxisSpacing: 10,
        ),

        itemBuilder: (context, i) {

          final santri = santriList[i];

          return FutureBuilder<double>(

            future:
                getProgress(santri['id']),

            builder: (context, snapshot) {

              double progress =
                  snapshot.data ?? 0;

              return InkWell(

                onTap: () async {

                  setState(() {
                    selectedSantri =
                        santri;
                  });

                  await fetchRiwayat(
                      santri['id']);
                },

                child: Container(

                  padding:
                      const EdgeInsets.all(
                          14),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                            20),

                    border:
                        Border.all(width: 1.5),
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(

                        "${santri['nama_lengkap']} | ${santri['kelas']}",

                        maxLines: 2,

                        overflow:
                            TextOverflow
                                .ellipsis,

                        style:
                            const TextStyle(

                          fontSize: 14,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        "Progres",
                      ),

                      const SizedBox(
                          height: 6),

                      Row(

                        children: [

                          Expanded(

                            child: ClipRRect(

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),

                              child:
                                  LinearProgressIndicator(

                                value:
                                    progress /
                                        100,

                                minHeight: 8,

                                backgroundColor:
                                    Colors.grey[
                                        300],
                              ),
                            ),
                          ),

                          const SizedBox(
                              width: 8),

                          Text(
                              "${progress.toInt()}%"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= CATAT HAFALAN =================
  Widget buildCatatanHafalan() {

    final santriId =
        selectedSantri!['id'];

    return SingleChildScrollView(

      padding:
          const EdgeInsets.all(16),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(

            selectedSantri![
                'nama_lengkap'],

            style: const TextStyle(

              fontSize: 22,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          TextField(

            controller:
                hafalanController,

            decoration: InputDecoration(

              labelText:
                  "Hafalan / Bab",

              hintText:
                  "Contoh : Bab I'rab - Bab Al-Af'ali",

              border:
                  OutlineInputBorder(

                borderRadius:
                    BorderRadius.circular(
                        16),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(

            shape:
                RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(
                      16),
            ),

            child: Column(

              children: [

                RadioListTile(

                  title:
                      const Text("Lancar"),

                  value: "Lancar",

                  groupValue:
                      penilaian,

                  activeColor:
                      Colors.lime[700],

                  onChanged: (v) {

                    setState(() {
                      penilaian = v;
                    });
                  },
                ),

                RadioListTile(

                  title: const Text(
                      "Kurang Lancar"),

                  value:
                      "Kurang Lancar",

                  groupValue:
                      penilaian,

                  activeColor:
                      Colors.lime[700],

                  onChanged: (v) {

                    setState(() {
                      penilaian = v;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(

            width: double.infinity,

            height: 52,

            child: ElevatedButton(

              style:
                  ElevatedButton.styleFrom(

                backgroundColor:
                    Colors.lime[400],

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                          14),
                ),
              ),

              onPressed: () =>
                  insertHafalan(
                      santriId),

              child: const Text(

                "Simpan Hafalan",

                style: TextStyle(

                  color: Colors.black,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(

            "Riwayat Hafalan",

            style: TextStyle(

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          loadingRiwayat

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : riwayatHafalan.isEmpty

                  ? const Text(
                      "Belum ada catatan")

                  : SingleChildScrollView(

                      scrollDirection:
                          Axis.horizontal,

                      child: DataTable(

                        columns: const [

                          DataColumn(
                              label: Text("No")),

                          DataColumn(
                              label:
                                  Text("Tanggal")),

                          DataColumn(
                              label:
                                  Text("Hafalan")),

                          DataColumn(
                              label:
                                  Text("Status")),

                          DataColumn(
                              label:
                                  Text("Aksi")),
                        ],

                        rows: List.generate(

                          riwayatHafalan.length,

                          (i) {

                            final item =
                                riwayatHafalan[
                                    i];

                            final tgl =
                                DateTime.parse(
                                    item[
                                        'tanggal']);

                            return DataRow(

                              cells: [

                                DataCell(
                                    Text(
                                        "${i + 1}")),

                                DataCell(

                                  Text(
                                    "${tgl.day}/${tgl.month}/${tgl.year}",
                                  ),
                                ),

                                DataCell(
                                  Text(item[
                                      'bagian']),
                                ),

                                DataCell(
                                  Text(item[
                                      'status']),
                                ),

                                DataCell(

                                  IconButton(

                                    icon:
                                        const Icon(

                                      Icons.delete,

                                      color:
                                          Colors
                                              .red,
                                    ),

                                    onPressed:
                                        () {

                                      showDialog(

                                        context:
                                            context,

                                        builder:
                                            (_) =>
                                                AlertDialog(

                                          title:
                                              const Text(
                                            "Hapus Catatan",
                                          ),

                                          content:
                                              const Text(
                                            "Yakin ingin menghapus?",
                                          ),

                                          actions: [

                                            TextButton(

                                              onPressed:
                                                  () {

                                                Navigator.pop(
                                                    context);
                                              },

                                              child:
                                                  const Text(
                                                      "Batal"),
                                            ),

                                            ElevatedButton(

                                              style:
                                                  ElevatedButton.styleFrom(

                                                backgroundColor:
                                                    Colors.red,
                                              ),

                                              onPressed:
                                                  () async {

                                                Navigator.pop(
                                                    context);

                                                await deleteHafalan(

                                                  hafalanId:
                                                      item[
                                                          'id'],

                                                  santriId:
                                                      santriId,
                                                );
                                              },

                                              child:
                                                  const Text(
                                                      "Hapus"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}