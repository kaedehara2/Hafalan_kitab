import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AwamilPage extends StatefulWidget {
  const AwamilPage({super.key});

  @override
  State<AwamilPage> createState() => _AwamilPageState();
}

class _AwamilPageState extends State<AwamilPage> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  bool loadingRiwayat = false;

  List<Map<String, dynamic>> santriList = [];
  Map<String, dynamic>? selectedSantri;

  List<Map<String, dynamic>> riwayatHafalan = [];

  double startIndex = 0;
  double endIndex = 0;
  String? penilaian;

  final List<String> babList = [
    "Muqadimmah",
    "Warna ke 1",
    "Warna ke 2",
    "Warna ke 3",
    "Warna ke 4",
    "Warna ke 5",
    "Warna ke 6",
    "Warna ke 7",
    "Warna ke 8",
    "Warna ke 9",
    "Warna ke 10",
    "Warna ke 11",
    "Warna ke 12",
    "Warna ke 13",
    "Qiyâsi",
    "Ma'nawi",
  ];

  @override
  void initState() {
    super.initState();
    fetchSantri();
  }

  // ================= FETCH SANTRI =================
  Future<void> fetchSantri() async {
    setState(() => loading = true);

    final data = await supabase
        .from('santri')
        .select('id, nama_lengkap, kelas')
        .order('nama_lengkap');

    if (!mounted) return;

    setState(() {
      santriList = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  // ================= FETCH RIWAYAT =================
  Future<void> fetchRiwayat(int santriId) async {
    setState(() => loadingRiwayat = true);

    final data = await supabase
        .from('hafalan_santri')
        .select()
        .eq('santri_id', santriId)
        .eq('kitab', 'awamil')
        .order('tanggal', ascending: false);

    if (!mounted) return;

    setState(() {
      riwayatHafalan = List<Map<String, dynamic>>.from(data);
      loadingRiwayat = false;
    });
  }

  // ================= HITUNG PROGRESS =================
  Future<double> getProgress(int santriId) async {
    final data = await supabase
        .from('hafalan_santri')
        .select('bagian_awal, bagian_akhir')
        .eq('santri_id', santriId)
        .eq('kitab', 'awamil');

    double totalProgress = 0;

    for (var item in data) {
      final awal = item['bagian_awal'];
      final akhir = item['bagian_akhir'];

      int start = babList.indexOf(awal);
      int end = babList.indexOf(akhir);

      if (start != -1 && end != -1 && end >= start) {
        int jumlahBagian = (end - start) + 1;
        totalProgress += jumlahBagian * 3;
      }
    }

    if (totalProgress > 100) {
      totalProgress = 100;
    }

    return totalProgress;
  }

  // ================= CEK KHATAM =================
  Future<void> cekDanKirimKhataman(int santriId) async {
    final progress = await getProgress(santriId);

    if (progress >= 100) {
      final cekData = await supabase
          .from('setoran_khataman')
          .select()
          .eq('santri_id', santriId)
          .eq('kitab', 'awamil');

      // jika belum pernah dikirim
      if (cekData.isEmpty) {
        await supabase.from('setoran_khataman').insert({
          'santri_id': santriId,
          'kitab': 'awamil',
          'status': 'pending',
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Santri berhasil dikirim ke setoran khataman",
            ),
          ),
        );
      }
    }
  }

  // ================= INSERT HAFALAN =================
  Future<void> insertHafalan(int santriId) async {
    if (penilaian == null) return;

    final bagianAwal = babList[startIndex.toInt()];
    final bagianAkhir = babList[endIndex.toInt()];

    final bagianText =
        startIndex == endIndex ? bagianAwal : "$bagianAwal - $bagianAkhir";

    await supabase.from('hafalan_santri').insert({
      'santri_id': santriId,
      'kitab': 'awamil',
      'bagian_awal': bagianAwal,
      'bagian_akhir': bagianAkhir,
      'bagian': bagianText,
      'status': penilaian,
    });

    // refresh langsung
    await fetchRiwayat(santriId);

    // cek khatam
    await cekDanKirimKhataman(santriId);

    if (!mounted) return;

    setState(() {
      startIndex = 0;
      endIndex = 0;
      penilaian = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Hafalan berhasil disimpan"),
      ),
    );
  }

  // ================= DELETE HAFALAN =================
  Future<void> deleteHafalan({
    required int hafalanId,
    required int santriId,
  }) async {
    await supabase
        .from('hafalan_santri')
        .delete()
        .eq('id', hafalanId);

    // refresh langsung
    await fetchRiwayat(santriId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Catatan hafalan berhasil dihapus"),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: selectedSantri != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedSantri = null;
                    riwayatHafalan.clear();
                  });
                },
              )
            : null,
        title: const Text("Kitab Awamil - Catat Hafalan"),
        backgroundColor: Colors.lime[400],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, i) {
          final santri = santriList[i];

          return FutureBuilder<double>(
            future: getProgress(santri['id']),
            builder: (context, snapshot) {
              double progress = snapshot.data ?? 0;

              return InkWell(
                onTap: () async {
                  setState(() {
                    selectedSantri = santri;
                  });

                  await fetchRiwayat(santri['id']);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${santri['nama_lengkap']} | ${santri['kelas']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text("Progres"),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                minHeight: 8,
                                backgroundColor: Colors.grey[300],
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text("${progress.toInt()}%"),
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
    final santriId = selectedSantri!['id'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedSantri!['nama_lengkap'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Dari: ${babList[startIndex.toInt()]}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          Slider(
            activeColor: Colors.lime[400],
            value: startIndex,
            min: 0,
            max: (babList.length - 1).toDouble(),
            divisions: babList.length - 1,
            onChanged: (v) {
              setState(() {
                startIndex = v;

                if (endIndex < v) {
                  endIndex = v;
                }
              });
            },
          ),

          const SizedBox(height: 10),

          Text(
            "Sampai: ${babList[endIndex.toInt()]}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          Slider(
            activeColor: Colors.lime[400],
            value: endIndex,
            min: startIndex,
            max: (babList.length - 1).toDouble(),
            divisions: babList.length - 1,
            onChanged: (v) {
              setState(() {
                endIndex = v;
              });
            },
          ),

          const SizedBox(height: 10),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                RadioListTile(
                  title: const Text("Lancar"),
                  value: "Lancar",
                  groupValue: penilaian,
                  activeColor: Colors.lime[700],
                  onChanged: (v) {
                    setState(() {
                      penilaian = v;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text("Kurang Lancar"),
                  value: "Kurang Lancar",
                  groupValue: penilaian,
                  activeColor: Colors.lime[700],
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
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lime[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: penilaian == null
                  ? null
                  : () => insertHafalan(santriId),
              child: const Text(
                "Simpan Hafalan",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

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
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              : riwayatHafalan.isEmpty
                  ? const Text("Belum ada catatan")
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("No")),
                          DataColumn(label: Text("Tanggal")),
                          DataColumn(label: Text("Hafalan")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Aksi")),
                        ],
                        rows: List.generate(riwayatHafalan.length, (i) {
                          final item = riwayatHafalan[i];

                          final tgl =
                              DateTime.parse(item['tanggal']);

                          return DataRow(
                            cells: [
                              DataCell(Text("${i + 1}")),

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
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text(
                                          "Hapus Catatan Hafalan",
                                        ),
                                        content: const Text(
                                          "Yakin ingin menghapus catatan ini?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Batal"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(context);

                                              await deleteHafalan(
                                                hafalanId: item['id'],
                                                santriId: santriId,
                                              );
                                            },
                                            child: const Text("Hapus"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
        ],
      ),
    );
  }
}