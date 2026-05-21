import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImrithiPage extends StatefulWidget {

  final String username;

  const ImrithiPage({
    super.key,
    required this.username,
  });

  @override
  State<ImrithiPage> createState() =>
      _ImrithiPageState();
}

class _ImrithiPageState
    extends State<ImrithiPage> {

  final supabase = Supabase.instance.client;

  bool loading = true;
  bool loadingRiwayat = false;

  List<Map<String, dynamic>> santriList = [];

  Map<String, dynamic>? selectedSantri;

  List<Map<String, dynamic>> riwayatHafalan = [];

  Map<String, dynamic>? selectedBab;

  final TextEditingController baitAwalController =
      TextEditingController();

  final TextEditingController baitAkhirController =
      TextEditingController();

  String? penilaian;

  // ================= DATA BAB IMRITHI =================
  final List<Map<String, dynamic>> babList = [

    {
      "nama": "Muqoddimah",
      "awal": 1,
      "akhir": 16,
    },

    {
      "nama": "Bab Al-Kalam",
      "awal": 17,
      "akhir": 26,
    },

    {
      "nama": "Bab Al-I'rab",
      "awal": 27,
      "akhir": 35,
    },

    {
      "nama": "Bab Alamatul I'rab",
      "awal": 36,
      "akhir": 70,
    },

    {
      "nama": "Bab Al-Af'al",
      "awal": 71,
      "akhir": 84,
    },

    {
      "nama": "Bab Al-Af'al Fi'li",
      "awal": 85,
      "akhir": 100,
    },

    {
      "nama": "Bab Isim-Isim",
      "awal": 101,
      "akhir": 104,
    },

    {
      "nama": "Bab Al-Fa'il",
      "awal": 105,
      "akhir": 114,
    },

    {
      "nama": "Bab Naibul Fa'il",
      "awal": 115,
      "akhir": 121,
    },

    {
      "nama": "Bab Mubtada Wa Khabar",
      "awal": 122,
      "akhir": 136,
    },

    {
      "nama": "Bab Inna Wa Akhwatuha",
      "awal": 137,
      "akhir": 146,
    },

    {
      "nama": "Bab Kana Wa Akhwatuha",
      "awal": 147,
      "akhir": 155,
    },

    {
      "nama": "Bab Dzonna",
      "awal": 156,
      "akhir": 161,
    },

    {
      "nama": "Bab At-Tabi'",
      "awal": 162,
      "akhir": 188,
    },

    {
      "nama": "Bab Isim-Isim Manshub",
      "awal": 189,
      "akhir": 230,
    },

    {
      "nama": "Bab Isim-Isim Makhfudh",
      "awal": 231,
      "akhir": 249,
    },

    {
      "nama": "Khotimah",
      "awal": 250,
      "akhir": 254,
    },
  ];

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

          .select('id, nama_lengkap, kelas')

          .eq('marhalah', 'Marhalah 3')

          .order('nama_lengkap');

      if (!mounted) return;

      setState(() {

        santriList =
            List<Map<String, dynamic>>.from(data);

        loading = false;
      });

    } catch (e) {

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content:
              Text("Gagal mengambil data santri: $e"),
        ),
      );
    }
  }

  // ================= FETCH RIWAYAT =================
  Future<void> fetchRiwayat(int santriId) async {

    setState(() => loadingRiwayat = true);

    try {

      final data = await supabase

          .from('hafalan_santri')

          .select()

          .eq('santri_id', santriId)

          .eq('kitab', 'imrithi')

          .order('tanggal', ascending: false);

      if (!mounted) return;

      setState(() {

        riwayatHafalan =
            List<Map<String, dynamic>>.from(data);

        loadingRiwayat = false;
      });

    } catch (e) {

      setState(() => loadingRiwayat = false);

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content:
              Text("Gagal mengambil riwayat: $e"),
        ),
      );
    }
  }

  // ================= HITUNG PROGRESS =================
  Future<double> getProgress(int santriId) async {

    try {

      final data = await supabase

          .from('hafalan_santri')

          .select('bagian_awal, bagian_akhir')

          .eq('santri_id', santriId)

          .eq('kitab', 'imrithi');

      int totalBait = 0;

      for (var item in data) {

        final awal =
            int.tryParse(item['bagian_awal'].toString()) ?? 0;

        final akhir =
            int.tryParse(item['bagian_akhir'].toString()) ?? 0;

        totalBait += (akhir - awal) + 1;
      }

      double progress =
          (totalBait / 254) * 100;

      if (progress > 100) {
        progress = 100;
      }

      return progress;

    } catch (e) {

      return 0;
    }
  }

  // ================= INSERT HAFALAN =================
  Future<void> insertHafalan(int santriId) async {

    if (selectedBab == null ||
        penilaian == null ||
        baitAwalController.text.isEmpty ||
        baitAkhirController.text.isEmpty) {
      return;
    }

    try {

      int baitAwal =
          int.parse(baitAwalController.text);

      int baitAkhir =
          int.parse(baitAkhirController.text);

      int batasAwal = selectedBab!['awal'];
      int batasAkhir = selectedBab!['akhir'];

      // ================= VALIDASI =================
      if (baitAwal < batasAwal ||
          baitAkhir > batasAkhir ||
          baitAwal > baitAkhir) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            backgroundColor: Colors.red,

            content: Text(
              "Rentang bait tidak sesuai dengan bab",
            ),
          ),
        );

        return;
      }

      final bagianText =
          "${selectedBab!['nama']} ($baitAwal - $baitAkhir)";

      await supabase.from('hafalan_santri').insert({

        'santri_id': santriId,

        'kitab': 'imrithi',

        'bagian_awal': baitAwal.toString(),

        'bagian_akhir': baitAkhir.toString(),

        'bagian': bagianText,

        'status': penilaian,

        'pembimbing_input':
            widget.username,

        'is_setoran_cadangan': false,
      });

      await fetchRiwayat(santriId);

      await fetchSantri();

      if (!mounted) return;

      setState(() {

        selectedBab = null;

        baitAwalController.clear();

        baitAkhirController.clear();

        penilaian = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content:
              Text("Hafalan berhasil disimpan"),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content:
              Text("Gagal menyimpan hafalan: $e"),
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

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content:
              Text("Catatan berhasil dihapus"),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content:
              Text("Gagal menghapus: $e"),
        ),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor: Colors.lime[400],

        title: const Text(
          "Kitab Imrithi - Catat Hafalan",
        ),

        leading: selectedSantri != null

            ? IconButton(

                icon:
                    const Icon(Icons.arrow_back),

                onPressed: () {

                  setState(() {

                    selectedSantri = null;

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

      padding: const EdgeInsets.all(12),

      child: GridView.builder(

        itemCount: santriList.length,

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount: 2,

          childAspectRatio: 2.6,

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

                    selectedSantri = santri;
                  });

                  await fetchRiwayat(
                      santri['id']);
                },

                child: Container(

                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(22),

                    border:
                        Border.all(width: 2),
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        "${santri['nama_lengkap']} | ${santri['kelas']}",

                        style: const TextStyle(

                          fontSize: 16,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text("Progres"),

                      const SizedBox(height: 6),

                      Row(

                        children: [

                          Expanded(

                            child: ClipRRect(

                              borderRadius:
                                  BorderRadius.circular(12),

                              child:
                                  LinearProgressIndicator(

                                value:
                                    progress / 100,

                                minHeight: 8,

                                backgroundColor:
                                    Colors.grey[300],
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

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

      padding: const EdgeInsets.all(16),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(

            selectedSantri!['nama_lengkap'],

            style: const TextStyle(

              fontSize: 20,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // ================= PILIH BAB =================
          DropdownButtonFormField<Map<String, dynamic>>(

            value: selectedBab,

            decoration: InputDecoration(

              labelText: "Pilih Bab",

              border: OutlineInputBorder(

                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),

            items: babList.map((bab) {

              return DropdownMenuItem(

                value: bab,

                child: Text(
                  bab['nama'],
                ),
              );
            }).toList(),

            onChanged: (v) {

              setState(() {

                selectedBab = v;
              });
            },
          ),

          const SizedBox(height: 20),

          // ================= BAIT AWAL =================
          TextField(

            controller: baitAwalController,

            keyboardType:
                TextInputType.number,

            decoration: InputDecoration(

              labelText: "Bait Awal",

              border: OutlineInputBorder(

                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ================= BAIT AKHIR =================
          TextField(

            controller: baitAkhirController,

            keyboardType:
                TextInputType.number,

            decoration: InputDecoration(

              labelText: "Bait Akhir",

              border: OutlineInputBorder(

                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ================= STATUS =================
          Card(

            shape: RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Column(

              children: [

                RadioListTile(

                  title:
                      const Text("Lancar"),

                  value: "Lancar",

                  groupValue: penilaian,

                  activeColor:
                      Colors.lime[700],

                  onChanged: (v) {

                    setState(() {

                      penilaian = v;
                    });
                  },
                ),

                RadioListTile(

                  title:
                      const Text("Kurang Lancar"),

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

          // ================= BUTTON =================
          SizedBox(

            width: double.infinity,

            height: 50,

            child: ElevatedButton(

              style:
                  ElevatedButton.styleFrom(

                backgroundColor:
                    Colors.lime[400],

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),

              onPressed:
                  penilaian == null

                      ? null

                      : () => insertHafalan(
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

          // ================= RIWAYAT =================
          const Text(

            "Riwayat Hafalan",

            style: TextStyle(

              fontWeight: FontWeight.bold,

              fontSize: 18,
            ),
          ),

          const SizedBox(height: 10),

          loadingRiwayat

              ? const Padding(

                  padding:
                      EdgeInsets.all(16),

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
                                riwayatHafalan[i];

                            final tgl =
                                DateTime.parse(
                                    item['tanggal']);

                            return DataRow(

                              cells: [

                                DataCell(
                                    Text("${i + 1}")),

                                DataCell(

                                  Text(
                                    "${tgl.day}/${tgl.month}/${tgl.year}",
                                  ),
                                ),

                                DataCell(
                                  Text(item['bagian']),
                                ),

                                DataCell(
                                  Text(item['status']),
                                ),

                                DataCell(

                                  IconButton(

                                    icon:
                                        const Icon(

                                      Icons.delete,

                                      color:
                                          Colors.red,
                                    ),

                                    onPressed: () {

                                      showDialog(

                                        context:
                                            context,

                                        builder: (_) =>
                                            AlertDialog(

                                          title:
                                              const Text(
                                            "Hapus Catatan",
                                          ),

                                          content:
                                              const Text(
                                            "Yakin ingin menghapus catatan hafalan?",
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
                                                      item['id'],

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
