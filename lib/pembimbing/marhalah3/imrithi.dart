import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model untuk mendefinisikan struktur bab & bait kitab Imrithi
class BabImrithi {
  final int id;
  final String nama;
  final int jumlahBait;

  const BabImrithi({
    required this.id,
    required this.nama,
    required this.jumlahBait,
  });
}

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

  String? penilaian;

  // Mode Setoran: 'satu_bab', 'lintas_bab', atau 'khatam'
  String modeSetoran = 'satu_bab';

  // ================= MASTER DATA BAB KITAB IMRITHI =================
  final List<BabImrithi> listBab = const [
    BabImrithi(id: 1, nama: "Muqaddimah", jumlahBait: 15),
    BabImrithi(id: 2, nama: "Bab Al-I'rab", jumlahBait: 12),
    BabImrithi(id: 3, nama: "Bab 'Alamat Al-I'rab", jumlahBait: 22),
    BabImrithi(id: 4, nama: "Bab Al-Ma'rifah wat Nakirah", jumlahBait: 10),
    BabImrithi(id: 5, nama: "Bab Al-Af'al", jumlahBait: 18),
    BabImrithi(id: 6, nama: "Bab Marfu'at Al-Asma'", jumlahBait: 8),
    BabImrithi(id: 7, nama: "Bab Al-Fa'il", jumlahBait: 10),
    BabImrithi(id: 8, nama: "Bab Na'ib Al-Fa'il", jumlahBait: 7),
    BabImrithi(id: 9, nama: "Bab Al-Mubtada' wal Khabar", jumlahBait: 16),
    BabImrithi(id: 10, nama: "Bab Kana wa Akhawatuha", jumlahBait: 11),
    BabImrithi(id: 11, nama: "Bab Inna wa Akhawatuha", jumlahBait: 10),
    BabImrithi(id: 12, nama: "Bab Zhanna wa Akhawatuha", jumlahBait: 8),
    BabImrithi(id: 13, nama: "Bab An-Na'at", jumlahBait: 10),
    BabImrithi(id: 14, nama: "Bab Al-'Athaf", jumlahBait: 9),
    BabImrithi(id: 15, nama: "Bab At-Taukid", jumlahBait: 7),
    BabImrithi(id: 16, nama: "Bab Al-Badal", jumlahBait: 8),
    BabImrithi(id: 17, nama: "Bab Manshubat Al-Asma'", jumlahBait: 6),
    BabImrithi(id: 18, nama: "Bab Al-Maf'ul Bih", jumlahBait: 8),
    BabImrithi(id: 19, nama: "Bab Al-Masdar (Al-Maf'ul Al-Muthlaq)", jumlahBait: 9),
    BabImrithi(id: 20, nama: "Bab Dazharf Al-Makan waz Zhaman", jumlahBait: 8),
    BabImrithi(id: 21, nama: "Bab Al-Hal", jumlahBait: 10),
    BabImrithi(id: 22, nama: "Bab At-Tamyiz", jumlahBait: 8),
    BabImrithi(id: 23, nama: "Bab Al-Istitsna'", jumlahBait: 11),
    BabImrithi(id: 24, nama: "Bab Laa An-Nafiyah lil Jins", jumlahBait: 7),
    BabImrithi(id: 25, nama: "Bab An-Nida'", jumlahBait: 8),
    BabImrithi(id: 26, nama: "Bab Al-Maf'ul Min Ajlih", jumlahBait: 5),
    BabImrithi(id: 27, nama: "Bab Al-Maf'ul Ma'ah", jumlahBait: 6),
    BabImrithi(id: 28, nama: "Bab Al-Makhfudhati Minal Asma'", jumlahBait: 13),
  ];

  late int totalTargetBait;

  // State Pilihan Lintas Bab
  BabImrithi? babAwal;
  int baitAwal = 1;

  BabImrithi? babAkhir;
  int baitAkhir = 1;

  @override
  void initState() {
    super.initState();
    totalTargetBait = listBab.fold(0, (sum, item) => sum + item.jumlahBait);
    if (listBab.isNotEmpty) {
      babAwal = listBab.first;
      babAkhir = listBab.first;
      baitAwal = 1;
      baitAkhir = listBab.first.jumlahBait;
    }
    fetchSantri();
  }

  // ================= KALKULASI BAIT PRESISI =================
  int get calculatedTotalBait {
    if (modeSetoran == 'khatam') {
      return totalTargetBait;
    }

    if (babAwal == null || babAkhir == null) return 0;

    int idxAwal = listBab.indexWhere((b) => b.id == babAwal!.id);
    int idxAkhir = listBab.indexWhere((b) => b.id == babAkhir!.id);

    if (idxAwal > idxAkhir) return 0; // Invalid Bab

    if (idxAwal == idxAkhir) {
      // Jika di Bab yang sama
      if (baitAwal > baitAkhir) return 0;
      return (baitAkhir - baitAwal) + 1;
    } else {
      // Jika Lintas Bab
      int total = 0;
      // Bab Pertama: Dari baitAwal sampai bait terakhir bab tsb
      total += (babAwal!.jumlahBait - baitAwal + 1);

      // Bab-bab Tengah: Hitung full
      for (int i = idxAwal + 1; i < idxAkhir; i++) {
        total += listBab[i].jumlahBait;
      }

      // Bab Terakhir: Dari bait 1 sampai baitAkhir
      total += baitAkhir;

      return total;
    }
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
        SnackBar(content: Text("Gagal mengambil data santri: $e")),
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
        SnackBar(content: Text("Gagal mengambil riwayat: $e")),
      );
    }
  }

  // ================= HITUNG PROGRESS =================
  Future<double> getProgress(int santriId) async {
    try {
      final data = await supabase
          .from('hafalan_santri')
          .select('jumlah_bait, status')
          .eq('santri_id', santriId)
          .eq('kitab', 'imrithi');

      int totalBait = 0;
      for (var item in data) {
        if (item['status'] == 'Lancar') {
          final jumlah = int.tryParse(item['jumlah_bait'].toString()) ?? 0;
          totalBait += jumlah;
        }
      }

      double progress = (totalBait / totalTargetBait) * 100;
      if (progress > 100) progress = 100;
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
    if (penilaian == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih hasil penilaian")),
      );
      return;
    }

    if (calculatedTotalBait <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Urutan Bab atau Bait tidak valid!")),
      );
      return;
    }

    try {
      String strBagian = "";
      String strBagianAwal = "";
      String strBagianAkhir = "";

      if (modeSetoran == 'khatam') {
        strBagian = "Full Kitab Imrithi (Khatam - 254 Bait)";
        strBagianAwal = "${listBab.first.nama} (Bait 1)";
        strBagianAkhir = "${listBab.last.nama} (Bait ${listBab.last.jumlahBait})";
      } else if (modeSetoran == 'satu_bab') {
        final bab = babAwal!;
        strBagianAwal = "${bab.nama} (Bait $baitAwal)";
        strBagianAkhir = "${bab.nama} (Bait $baitAkhir)";
        strBagian = (baitAwal == baitAkhir)
            ? "${bab.nama} (Bait $baitAwal)"
            : "${bab.nama} (Bait $baitAwal - $baitAkhir)";
      } else {
        // Lintas Bab
        strBagianAwal = "${babAwal!.nama} (Bait $baitAwal)";
        strBagianAkhir = "${babAkhir!.nama} (Bait $baitAkhir)";
        strBagian = "$strBagianAwal s/d $strBagianAkhir";
      }

      await supabase.from('hafalan_santri').insert({
        'santri_id': santriId,
        'kitab': 'imrithi',
        'bagian': strBagian,
        'bagian_awal': strBagianAwal,
        'bagian_akhir': strBagianAkhir,
        'jumlah_bait': calculatedTotalBait,
        'status': penilaian,
        'pembimbing_input': widget.username,
        'mode_setoran': modeSetoran,
        'is_setoran_cadangan': false,
      });

      await fetchRiwayat(santriId);
      await fetchSantri();
      await cekDanKirimKhataman(santriId);

      if (!mounted) return;

      setState(() {
        penilaian = null;
        if (listBab.isNotEmpty) {
          babAwal = listBab.first;
          babAkhir = listBab.first;
          baitAwal = 1;
          baitAkhir = listBab.first.jumlahBait;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hafalan berhasil disimpan")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan hafalan: $e")),
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
        const SnackBar(content: Text("Catatan berhasil dihapus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus: $e")),
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

  // ================= LIST SANTRI =================
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.lime[700]!),
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
          // Header Nama Santri
          Card(
            elevation: 0,
            color: Colors.lime[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.lime[300]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedSantri!['nama_lengkap'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // TOGGLE MODE SETORAN
          const Text(
            "Pilih Cakupan Setoran",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'satu_bab',
                label: Text('Dalam 1 Bab'),
                icon: Icon(Icons.bookmark),
              ),
              ButtonSegment(
                value: 'lintas_bab',
                label: Text('Lintas Bab'),
                icon: Icon(Icons.import_contacts),
              ),
              ButtonSegment(
                value: 'khatam',
                label: Text('Full / Khatam'),
                icon: Icon(Icons.stars),
              ),
            ],
            selected: {modeSetoran},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                modeSetoran = newSelection.first;
                if (modeSetoran == 'satu_bab') {
                  babAkhir = babAwal;
                  baitAkhir = babAwal?.jumlahBait ?? 1;
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // FORM INPUTAN SESUAI MODE
          if (modeSetoran == 'khatam') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber[400]!),
              ),
              child: const Column(
                children: [
                  Icon(Icons.workspace_premium, size: 40, color: Colors.amber),
                  SizedBox(height: 8),
                  Text(
                    "Setoran Full Kitab (Khatam)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Santri akan disetor seluruh 254 bait dari Bab Muqaddimah hingga Bab Akhir.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ] else if (modeSetoran == 'satu_bab') ...[
            buildFormSatuBab(),
          ] else ...[
            buildFormLintasBab(),
          ],

          const SizedBox(height: 14),

          // RINGKASAN BAIT AUTOMATIS
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: calculatedTotalBait > 0 ? Colors.lime[100] : Colors.red[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: calculatedTotalBait > 0 ? Colors.lime[700]! : Colors.red[300]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  calculatedTotalBait > 0
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: calculatedTotalBait > 0 ? Colors.lime[900] : Colors.red,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: calculatedTotalBait > 0
                      ? Text(
                          "Total Disetor: $calculatedTotalBait Bait",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.lime[900],
                            fontSize: 15,
                          ),
                        )
                      : const Text(
                          "Urutan Bab/Bait tidak valid!",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Penilaian / Status Setoran
          const Text(
            "Hasil Penilaian",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.grey, width: 0.8),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
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
                RadioListTile<String>(
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

          // Tombol Simpan
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
              onPressed: (penilaian == null || calculatedTotalBait <= 0)
                  ? null
                  : () => insertHafalan(santriId),
              child: const Text(
                "Simpan Hafalan",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Riwayat Hafalan
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
                  child: Center(child: CircularProgressIndicator()),
                )
              : riwayatHafalan.isEmpty
                  ? const Text("Belum ada catatan setoran")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: riwayatHafalan.length,
                      itemBuilder: (context, i) {
                        final item = riwayatHafalan[i];
                        final tgl = DateTime.parse(item['tanggal']);
                        final isLancar = item['status'] == 'Lancar';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isLancar ? Colors.green : Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isLancar
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                              child: Icon(
                                isLancar ? Icons.check : Icons.priority_high,
                                color: isLancar
                                    ? Colors.green[800]
                                    : Colors.orange[800],
                              ),
                            ),
                            title: Text(
                              item['bagian'] ?? "-",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Tanggal: ${tgl.day}/${tgl.month}/${tgl.year} | Status: ${item['status']}",
                            ),
                            trailing: IconButton(
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
                                      "Yakin ingin menghapus catatan hafalan ini?",
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
                        );
                      },
                    ),
        ],
      ),
    );
  }

  // ================= FORM SATU BAB =================
  Widget buildFormSatuBab() {
    final int maxBait = babAwal?.jumlahBait ?? 1;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.grey, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            DropdownButtonFormField<BabImrithi>(
              value: babAwal,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Pilih Bab",
                prefixIcon: Icon(Icons.menu_book),
                border: OutlineInputBorder(),
              ),
              items: listBab.map((bab) {
                return DropdownMenuItem<BabImrithi>(
                  value: bab,
                  child: Text(
                    "${bab.id}. ${bab.nama} (${bab.jumlahBait} Bait)",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    babAwal = val;
                    babAkhir = val;
                    baitAwal = 1;
                    baitAkhir = val.jumlahBait;
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: baitAwal <= maxBait ? baitAwal : 1,
                    decoration: const InputDecoration(
                      labelText: "Dari Bait",
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(maxBait, (i) => i + 1).map((b) {
                      return DropdownMenuItem<int>(value: b, child: Text("Bait $b"));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          baitAwal = val;
                          if (baitAkhir < val) baitAkhir = val;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: baitAkhir <= maxBait ? baitAkhir : maxBait,
                    decoration: const InputDecoration(
                      labelText: "Sampai Bait",
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(maxBait, (i) => i + 1).map((b) {
                      return DropdownMenuItem<int>(value: b, child: Text("Bait $b"));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          baitAkhir = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= FORM LINTAS BAB =================
  Widget buildFormLintasBab() {
    final int maxBaitAwal = babAwal?.jumlahBait ?? 1;
    final int maxBaitAkhir = babAkhir?.jumlahBait ?? 1;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.grey, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mulai Dari:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<BabImrithi>(
              value: babAwal,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Bab Awal",
                prefixIcon: Icon(Icons.start),
                border: OutlineInputBorder(),
              ),
              items: listBab.map((bab) {
                return DropdownMenuItem<BabImrithi>(
                  value: bab,
                  child: Text("${bab.id}. ${bab.nama}"),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    babAwal = val;
                    baitAwal = 1;
                    if (babAkhir == null || babAkhir!.id < val.id) {
                      babAkhir = val;
                      baitAkhir = val.jumlahBait;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: baitAwal <= maxBaitAwal ? baitAwal : 1,
              decoration: const InputDecoration(
                labelText: "Dari Bait Ke-",
                border: OutlineInputBorder(),
              ),
              items: List.generate(maxBaitAwal, (i) => i + 1).map((b) {
                return DropdownMenuItem<int>(value: b, child: Text("Bait $b"));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => baitAwal = val);
                }
              },
            ),

            const Divider(height: 30, thickness: 1),

            const Text(
              "Sampai Dengan:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<BabImrithi>(
              value: babAkhir,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Bab Akhir",
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              items: listBab.map((bab) {
                return DropdownMenuItem<BabImrithi>(
                  value: bab,
                  child: Text("${bab.id}. ${bab.nama}"),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    babAkhir = val;
                    baitAkhir = val.jumlahBait;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: baitAkhir <= maxBaitAkhir ? baitAkhir : maxBaitAkhir,
              decoration: const InputDecoration(
                labelText: "Sampai Bait Ke-",
                border: OutlineInputBorder(),
              ),
              items: List.generate(maxBaitAkhir, (i) => i + 1).map((b) {
                return DropdownMenuItem<int>(value: b, child: Text("Bait $b"));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => baitAkhir = val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}