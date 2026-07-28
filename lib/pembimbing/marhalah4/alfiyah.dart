import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model untuk mendefinisikan struktur bab & bait kitab Alfiyah
class BabAlfiyah {
  final int id;
  final String nama;
  final int jumlahBait;

  const BabAlfiyah({
    required this.id,
    required this.nama,
    required this.jumlahBait,
  });
}

class AlfiyahPage extends StatefulWidget {
  final String username;

  const AlfiyahPage({
    super.key,
    required this.username,
  });

  @override
  State<AlfiyahPage> createState() => _AlfiyahPageState();
}

class _AlfiyahPageState extends State<AlfiyahPage> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  bool loadingRiwayat = false;

  List<Map<String, dynamic>> santriList = [];
  Map<String, dynamic>? selectedSantri;
  List<Map<String, dynamic>> riwayatHafalan = [];

  String? penilaian;

  // Mode Setoran: 'satu_bab', 'lintas_bab', atau 'khatam'
  String modeSetoran = 'satu_bab';

  // ================= MASTER DATA BAB KITAB ALFIYAH =================
  final List<BabAlfiyah> listBab = const [
    BabAlfiyah(id: 1, nama: "Muqaddimah", jumlahBait: 7),
    BabAlfiyah(id: 2, nama: "Kalam dan Pembentuknya (Al-Kalam wa Ma Yatallafu Minhu)", jumlahBait: 7),
    BabAlfiyah(id: 3, nama: "Mu'rab dan Mabni (Al-Mu'rab wa Al-Mabni)", jumlahBait: 28),
    BabAlfiyah(id: 4, nama: "Nakarah dan Ma'rifah (Al-Nakarah wa Al-Ma'rifah)", jumlahBait: 6),
    BabAlfiyah(id: 5, nama: "Dhamir (Al-Dhamir)", jumlahBait: 20),
    BabAlfiyah(id: 6, nama: "Alam (Al-'Alam)", jumlahBait: 8),
    BabAlfiyah(id: 7, nama: "Isim Isyarah (Ism Al-Isyarah)", jumlahBait: 8),
    BabAlfiyah(id: 8, nama: "Isim Maushul (Ism Al-Maushul)", jumlahBait: 17),
    BabAlfiyah(id: 9, nama: "Ma'rifat dengan Al (Al-Mu'arraf bi Alat Al-Ta'rif)", jumlahBait: 8),
    BabAlfiyah(id: 10, nama: "Ibtida' (Al-Ibtida')", jumlahBait: 44),
    BabAlfiyah(id: 11, nama: "Kana dan Saudaranya (Kana wa Akhawatuha)", jumlahBait: 22),
    BabAlfiyah(id: 12, nama: "Fasal Ma, La, Lata, dan In yang Beramal Seperti Laisa", jumlahBait: 8),
    BabAlfiyah(id: 13, nama: "Af'al Al-Muqarabah", jumlahBait: 11),
    BabAlfiyah(id: 14, nama: "Inna dan Saudaranya (Inna wa Akhawatuha)", jumlahBait: 24),
    BabAlfiyah(id: 15, nama: "La Nafeah lil Jins (La Al-Lati Li Nafi Al-Jins)", jumlahBait: 13),
    BabAlfiyah(id: 16, nama: "Zhanna dan Saudaranya (Zhanna wa Akhawatuha)", jumlahBait: 19),
    BabAlfiyah(id: 17, nama: "A'lama dan Ara (A'lama wa Ara)", jumlahBait: 6),
    BabAlfiyah(id: 18, nama: "Fa'il (Al-Fa'il)", jumlahBait: 22),
    BabAlfiyah(id: 19, nama: "Na'ib Fa'il (Al-Na'ib 'an Al-Fa'il)", jumlahBait: 9),
    BabAlfiyah(id: 20, nama: "Isytighal (Al-Isytighal)", jumlahBait: 12),
    BabAlfiyah(id: 21, nama: "Ta'addi dan Luzum (Al-Ta'addi wa Al-Luzum)", jumlahBait: 10),
    BabAlfiyah(id: 22, nama: "Tanaazu' (Al-Tanaazu' fi Al-'Amal)", jumlahBait: 8),
    BabAlfiyah(id: 23, nama: "Maf'ul Muthlaq (Al-Maf'ul Al-Muthlaq)", jumlahBait: 14),
    BabAlfiyah(id: 24, nama: "Maf'ul Lah / Maf'ul Li Ajlih (Al-Maf'ul Lahu)", jumlahBait: 4),
    BabAlfiyah(id: 25, nama: "Maf'ul Fih / Zharaf (Al-Maf'ul Fihi wa Huwa Al-Zharaf)", jumlahBait: 10),
    BabAlfiyah(id: 26, nama: "Maf'ul Ma'ah (Al-Maf'ul Ma'ahu)", jumlahBait: 6),
    BabAlfiyah(id: 27, nama: "Estepstna' (Al-Istitsna')", jumlahBait: 19),
    BabAlfiyah(id: 28, nama: "Hal (Al-Hal)", jumlahBait: 29),
    BabAlfiyah(id: 29, nama: "Tamyiz (Al-Tamyiz)", jumlahBait: 10),
    BabAlfiyah(id: 30, nama: "Huruf Jar (Huruf Al-Jarr)", jumlahBait: 26),
    BabAlfiyah(id: 31, nama: "Idhafah (Al-Idhafah)", jumlahBait: 38),
    BabAlfiyah(id: 32, nama: "Mudhaf pada Ya' Mutakallim (Al-Mudhaf ila Ya' Al-Mutakallim)", jumlahBait: 6),
    BabAlfiyah(id: 33, nama: "I'mal Al-Mashdar (I'mal Al-Mashdar)", jumlahBait: 7),
    BabAlfiyah(id: 34, nama: "I'mal Isim Fa'il (I'mal Ism Al-Fa'il)", jumlahBait: 10),
    BabAlfiyah(id: 35, nama: "Abniyah Mashadir (Abniyah Al-Mashadir)", jumlahBait: 18),
    BabAlfiyah(id: 36, nama: "Abniyah Asma' Al-Fa'ilin wa Al-Maf'ulin wa Al-Sifati Al-Musyabbahah", jumlahBait: 8),
    BabAlfiyah(id: 37, nama: "Sifat Musyabbahah (Al-Sifah Al-Musyabbahah bi Ism Al-Fa'il)", jumlahBait: 11),
    BabAlfiyah(id: 38, nama: "Ta'ajjub (Al-Ta'ajjub)", jumlahBait: 11),
    BabAlfiyah(id: 39, nama: "Ni'ma dan Bi'sa (Ni'ma wa Bi'sa wa Ma Jara Majrahuma)", jumlahBait: 10),
    BabAlfiyah(id: 40, nama: "Af'al Al-Tafdhil (Af'al Al-Tafdhil)", jumlahBait: 12),
    BabAlfiyah(id: 41, nama: "Na'at (Al-Na'at)", jumlahBait: 15),
    BabAlfiyah(id: 42, nama: "'Athaf Bayaan (Athf Al-Bayan)", jumlahBait: 7),
    BabAlfiyah(id: 43, nama: "'Athaf Nasaq (Athf Al-Nasaq)", jumlahBait: 22),
    BabAlfiyah(id: 44, nama: "Taukid (Al-Taukid)", jumlahBait: 10),
    BabAlfiyah(id: 45, nama: "Badal (Al-Badal)", jumlahBait: 10),
    BabAlfiyah(id: 46, nama: "Nida' (Al-Nida')", jumlahBait: 24),
    BabAlfiyah(id: 47, nama: "Munada Al-Mudhaf ila Ya' Al-Mutakallim", jumlahBait: 7),
    BabAlfiyah(id: 48, nama: "Asma' Al-Lati La Ta'tamilu Al-Nida' Ela bi Al-Dharurah", jumlahBait: 6),
    BabAlfiyah(id: 49, nama: "Istighatsah (Al-Istighatsah)", jumlahBait: 8),
    BabAlfiyah(id: 50, nama: "Nudbah (Al-Nudbah)", jumlahBait: 7),
    BabAlfiyah(id: 51, nama: "Tarkhim (Al-Tarkhim)", jumlahBait: 10),
    BabAlfiyah(id: 52, nama: "Ikhtishash (Al-Ikhtishash)", jumlahBait: 4),
    BabAlfiyah(id: 53, nama: "Isytighal bi Al-Thana' / Al-Tahdzir wa Al-Ighra'", jumlahBait: 7),
    BabAlfiyah(id: 54, nama: "Asma' Al-Af'al wa Al-Ashwat", jumlahBait: 12),
    BabAlfiyah(id: 55, nama: "Nun Taukid (Nunai Al-Taukid)", jumlahBait: 18),
    BabAlfiyah(id: 56, nama: "Ghairu Al-Munsharif (Al-Mamnu' min Al-Sarf)", jumlahBait: 30),
    BabAlfiyah(id: 57, nama: "I'rab Al-Fi'il (I'rab Al-Fi'il)", jumlahBait: 17),
    BabAlfiyah(id: 58, nama: "Amil Al-Jazm / Syarat (Al-Jawazim)", jumlahBait: 20),
    BabAlfiyah(id: 59, nama: "Lau, Laula, dan Lauma (Lau wa Laula wa Lauma)", jumlahBait: 7),
    BabAlfiyah(id: 60, nama: "Ama, Imma, dan Kamma (Ama wa Imma wa Kamma)", jumlahBait: 8),
    BabAlfiyah(id: 61, nama: "Khabar Inna, La, dan Isim Adat (Al-Khabar 'an Al-Ladhi)", jumlahBait: 9),
    BabAlfiyah(id: 62, nama: "العدد (Al-'Adad)", jumlahBait: 15),
    BabAlfiyah(id: 63, nama: "Kunayahi (Al-Kinayah)", jumlahBait: 4),
    BabAlfiyah(id: 64, nama: "Hikayah (Al-Hikayah)", jumlahBait: 6),
    BabAlfiyah(id: 65, nama: "Ta'nis (Al-Ta'nis)", jumlahBait: 10),
    BabAlfiyah(id: 66, nama: "Maqshur dan Mamdud (Al-Maqshur wa Al-Mamdud)", jumlahBait: 11),
    BabAlfiyah(id: 67, nama: "Kaifiyatu Taniyati Al-Maqshur wa Al-Mamdud wa Jam'ihima", jumlahBait: 17),
    BabAlfiyah(id: 68, nama: "Tashghir (Al-Tashghir)", jumlahBait: 28),
    BabAlfiyah(id: 69, nama: "Nasab (Al-Nasab)", jumlahBait: 36),
    BabAlfiyah(id: 70, nama: "I'lal dan Ibdal (Al-Ibdal wa Al-I'lal)", jumlahBait: 40),
    BabAlfiyah(id: 71, nama: "Fasl fi Al-Ibdal (Tathbiqat Al-Ibdal wa Al-I'lal)", jumlahBait: 15),
    BabAlfiyah(id: 72, nama: "Fasl fi Al-Khatm (Khatimah & Idgham)", jumlahBait: 20),
  ];

  late int totalTargetBait;

  // State Pilihan Lintas Bab
  BabAlfiyah? babAwal;
  int baitAwal = 1;

  BabAlfiyah? babAkhir;
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
          .eq('marhalah', 'Marhalah 4')
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
          .eq('kitab', 'alfiyah')
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
          .eq('kitab', 'alfiyah');

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
            .eq('kitab', 'alfiyah');

        if (cekData.isEmpty) {
          await supabase.from('setoran_khataman').insert({
            'santri_id': santriId,
            'kitab': 'alfiyah',
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
      debugPrint("ERROR KHATAMAN ALFIYAH : $e");
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
        strBagian = "Full Kitab Alfiyah (Khatam - $totalTargetBait Bait)";
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
        'kitab': 'alfiyah',
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
        backgroundColor: Colors.indigo[300],
        title: const Text("Kitab Alfiyah - Catat Hafalan"),
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
                                    Colors.indigo[600]!),
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
            color: Colors.indigo[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.indigo[300]!),
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
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo[400]!),
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, size: 40, color: Colors.indigo),
                  const SizedBox(height: 8),
                  const Text(
                    "Setoran Full Kitab (Khatam)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Santri akan disetor seluruh $totalTargetBait bait dari Bab Muqaddimah hingga Bab Khatimah.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87),
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
              color: calculatedTotalBait > 0 ? Colors.indigo[100] : Colors.red[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: calculatedTotalBait > 0 ? Colors.indigo[700]! : Colors.red[300]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  calculatedTotalBait > 0
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: calculatedTotalBait > 0 ? Colors.indigo[900] : Colors.red,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: calculatedTotalBait > 0
                      ? Text(
                          "Total Disetor: $calculatedTotalBait Bait",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[900],
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
                  activeColor: Colors.indigo[700],
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
                  activeColor: Colors.indigo[700],
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
                backgroundColor: Colors.indigo[300],
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
            DropdownButtonFormField<BabAlfiyah>(
              value: babAwal,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Pilih Bab",
                prefixIcon: Icon(Icons.menu_book),
                border: OutlineInputBorder(),
              ),
              items: listBab.map((bab) {
                return DropdownMenuItem<BabAlfiyah>(
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
                      return DropdownMenuItem<int>(
                          value: b, child: Text("Bait $b"));
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
                      return DropdownMenuItem<int>(
                          value: b, child: Text("Bait $b"));
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
            DropdownButtonFormField<BabAlfiyah>(
              value: babAwal,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Bab Awal",
                prefixIcon: Icon(Icons.start),
                border: OutlineInputBorder(),
              ),
              items: listBab.map((bab) {
                return DropdownMenuItem<BabAlfiyah>(
                  value: bab,
                  child: Text("${bab.id}. ${bab.nama}", overflow: TextOverflow.ellipsis),
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
                  setState(() {
                    baitAwal = val;
                  });
                }
              },
            ),
            const Divider(height: 30, thickness: 1),
            const Text(
              "Sampai Dengan:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<BabAlfiyah>(
              value: babAkhir,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Bab Akhir",
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              items: listBab.map((bab) {
                return DropdownMenuItem<BabAlfiyah>(
                  value: bab,
                  child: Text("${bab.id}. ${bab.nama}", overflow: TextOverflow.ellipsis),
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
                  setState(() {
                    baitAkhir = val;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}