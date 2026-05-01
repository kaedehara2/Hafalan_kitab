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
    final data = await supabase
        .from('santri')
        .select('id, nama_lengkap, kelas, progress_awamil')
        .order('nama_lengkap');

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
      int start = babList.indexOf(item['bagian_awal']);
      int end = babList.indexOf(item['bagian_akhir']);

      if (start != -1 && end != -1 && end >= start) {
        int jumlah = (end - start) + 1;
        totalProgress += jumlah * 3;
      }
    }

    if (totalProgress > 100) totalProgress = 100;

    return totalProgress;
  }

  // ================= UPDATE PROGRESS =================
  Future<void> updateProgress(int santriId) async {
    double progress = await getProgress(santriId);

    await supabase
        .from('santri')
        .update({'progress_awamil': progress})
        .eq('id', santriId);
  }

  // ================= INSERT =================
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

    await updateProgress(santriId);
    await fetchRiwayat(santriId);
    await fetchSantri();

    setState(() {
      startIndex = 0;
      endIndex = 0;
      penilaian = null;
    });
  }

  // ================= DELETE =================
  Future<void> deleteHafalan({
    required int hafalanId,
    required int santriId,
  }) async {
    await supabase.from('hafalan_santri').delete().eq('id', hafalanId);

    await updateProgress(santriId);
    await fetchRiwayat(santriId);
    await fetchSantri();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Catatan hafalan berhasil dihapus")),
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

  // ================= CARD SANTRI =================
  Widget buildListSantri() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: santriList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, i) {
          final santri = santriList[i];
          double progress = (santri['progress_awamil'] ?? 0).toDouble();

          return InkWell(
            onTap: () {
              setState(() => selectedSantri = santri);
              fetchRiwayat(santri['id']);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  )
                ],
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.lime[300],
                        child: Text(
                          santri['nama_lengkap'][0],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          santri['nama_lengkap'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    santri['kelas'],
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Spacer(),
                  const Text("Progress"),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("${progress.toInt()}%"),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= HALAMAN CATAT =================
  Widget buildCatatanHafalan() {
    final santriId = selectedSantri!['id'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedSantri!['nama_lengkap'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Text("Dari: ${babList[startIndex.toInt()]}"),
          Slider(
            value: startIndex,
            min: 0,
            max: (babList.length - 1).toDouble(),
            divisions: babList.length - 1,
            onChanged: (v) {
              setState(() {
                startIndex = v;
                if (endIndex < v) endIndex = v;
              });
            },
          ),

          Text("Sampai: ${babList[endIndex.toInt()]}"),
          Slider(
            value: endIndex,
            min: startIndex,
            max: (babList.length - 1).toDouble(),
            divisions: babList.length - 1,
            onChanged: (v) => setState(() => endIndex = v),
          ),

          RadioListTile(
            title: const Text("Lancar"),
            value: "Lancar",
            groupValue: penilaian,
            onChanged: (v) => setState(() => penilaian = v),
          ),
          RadioListTile(
            title: const Text("Kurang Lancar"),
            value: "Kurang Lancar",
            groupValue: penilaian,
            onChanged: (v) => setState(() => penilaian = v),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  penilaian == null ? null : () => insertHafalan(santriId),
              child: const Text("Simpan Hafalan"),
            ),
          ),

          const SizedBox(height: 24),
          const Text("Riwayat Hafalan",
              style: TextStyle(fontWeight: FontWeight.bold)),

          loadingRiwayat
              ? const Center(child: CircularProgressIndicator())
              : riwayatHafalan.isEmpty
                  ? const Text("Belum ada catatan")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: riwayatHafalan.length,
                      itemBuilder: (context, i) {
                        final item = riwayatHafalan[i];
                        final tgl = DateTime.parse(item['tanggal']);

                        return Card(
                          child: ListTile(
                            title: Text(item['bagian']),
                            subtitle: Text(
                                "${tgl.day}/${tgl.month}/${tgl.year} - ${item['status']}"),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteHafalan(
                                hafalanId: item['id'],
                                santriId: santriId,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
