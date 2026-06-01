import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImrithiPage extends StatefulWidget {
  final String username;

  const ImrithiPage({
    super.key,
    required this.username,
  });

  @override
  State<ImrithiPage> createState() => _ImrithiPageState();
}

class _ImrithiPageState extends State<ImrithiPage> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  bool loadingRiwayat = false;

  List<Map<String, dynamic>> santriList = [];
  Map<String, dynamic>? selectedSantri;
  List<Map<String, dynamic>> riwayatHafalan = [];

  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController jumlahBaitController = TextEditingController();

  String? penilaian;

  // ================= TOTAL TARGET BAIT =================
  final int totalTargetBait = 254;

  @override
  void initState() {
    super.initState();
    fetchSantri();
  }

  @override
  void dispose() {
    keteranganController.dispose();
    jumlahBaitController.dispose();
    super.dispose();
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
        santriList = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengambil data santri: $e"),
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
        riwayatHafalan = List<Map<String, dynamic>>.from(data);
        loadingRiwayat = false;
      });
    } catch (e) {
      setState(() => loadingRiwayat = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengambil riwayat: $e"),
        ),
      );
    }
  }

  // ================= HITUNG PROGRESS =================
  Future<double> getProgress(int santriId) async {
    try {
      final data = await supabase
          .from('hafalan_santri')
          .select('jumlah_bait')
          .eq('santri_id', santriId)
          .eq('kitab', 'imrithi');

      int totalBait = 0;
      for (var item in data) {
        final jumlah = int.tryParse(item['jumlah_bait'].toString()) ?? 0;
        totalBait += jumlah;
      }

      double progress = (totalBait / totalTargetBait) * 100;
      if (progress > 100) {
        progress = 100;
      }
      return progress;
    } catch (e) {
      debugPrint("ERROR HITUNG PROGRESS : $e");
      return 0;
    }
  }

  // ================= CEK KHATAMAN =================
  Future<void> cekDanKirimKhataman(int santriId) async {
    try {
      final progress = await getProgress(santriId);
      debugPrint("PROGRESS IMRITHI : $progress");

      if (progress >= 100) {
        final cekData = await supabase
            .from('setoran_khataman')
            .select()
            .eq('santri_id', santriId)
            .eq('kitab', 'imrithi');

        if (cekData.isEmpty) {
          await supabase.from('setoran_khataman').insert({
            'santri_id': santriId,
            'kitab': 'imrithi',
            'status': 'pending',
          });

          debugPrint("BERHASIL MASUK KHATAMAN IMRITHI");
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Santri berhasil masuk setoran khataman"),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("ERROR KHATAMAN IMRITHI : $e");
    }
  }

  // ================= INSERT HAFALAN =================
  Future<void> insertHafalan(int santriId) async {
    if (keteranganController.text.isEmpty ||
        jumlahBaitController.text.isEmpty ||
        penilaian == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lengkapi data hafalan"),
        ),
      );
      return;
    }

    try {
      final jumlahBait = int.parse(jumlahBaitController.text);

      await supabase.from('hafalan_santri').insert({
        'santri_id': santriId,
        'kitab': 'imrithi',
        'bagian': keteranganController.text,
        'jumlah_bait': jumlahBait,
        'status': penilaian,
        'pembimbing_input': widget.username,
        'is_setoran_cadangan': false,
      });

      await fetchRiwayat(santriId);
      await fetchSantri();
      await cekDanKirimKhataman(santriId);

      if (!mounted) return;

      setState(() {
        keteranganController.clear();
        jumlahBaitController.clear();
        penilaian = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hafalan berhasil disimpan"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan hafalan: $e"),
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
      await supabase.from('hafalan_santri').delete().eq('id', hafalanId);

      await fetchRiwayat(santriId);
      await fetchSantri();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Catatan berhasil dihapus"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghapus: $e"),
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
        title: const Text("Kitab Imrithi - Catat Hafalan"),
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
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : selectedSantri == null
              ? buildListSantri()
              : buildCatatanHafalan(),
    );
  }

  // ================= LIST SANTRI (REVISED TO ONE COLUMN & ONE LINE NAME) =================
  Widget buildListSantri() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: santriList.length,
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
                  margin: const EdgeInsets.only(bottom: 10),
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
                        "${santri['nama_lengkap']} | Kelas ${santri['kelas']}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text("Progres Hafalan"),
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
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${progress.toInt()}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
          TextField(
            controller: keteranganController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Keterangan Hafalan",
              hintText: "Contoh:\nBab Al-Kalam sampai Bab I'rab",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: jumlahBaitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Jumlah Bait",
              hintText: "Masukkan jumlah bait",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
              onPressed: penilaian == null ? null : () => insertHafalan(santriId),
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
                          DataColumn(label: Text("Jumlah")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Aksi")),
                        ],
                        rows: List.generate(
                          riwayatHafalan.length,
                          (i) {
                            final item = riwayatHafalan[i];
                            final tgl = DateTime.parse(item['tanggal']);

                            return DataRow(
                              cells: [
                                DataCell(Text("${i + 1}")),
                                DataCell(
                                  Text("${tgl.day}/${tgl.month}/${tgl.year}"),
                                ),
                                DataCell(Text(item['bagian'])),
                                DataCell(Text("${item['jumlah_bait']} bait")),
                                DataCell(Text(item['status'])),
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
                                          title: const Text("Hapus Catatan"),
                                          content: const Text(
                                            "Yakin ingin menghapus catatan hafalan?",
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
                          },
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}