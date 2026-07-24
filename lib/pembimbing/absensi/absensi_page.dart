import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AbsensiPage extends StatefulWidget {
  final String marhalah;
  final String idPembimbing;

  const AbsensiPage({
    super.key,
    required this.marhalah,
    required this.idPembimbing,
  });

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  bool isSaving = false;

  List<Map<String, dynamic>> santriList = [];
  Map<int, String> statusAbsensi = {};

  // Stat Rekapitulasi
  int jumlahHadir = 0;
  int jumlahIzin = 0;
  int jumlahSakit = 0;
  int jumlahTidakHadir = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void hitungStatistik() {
    jumlahHadir = 0;
    jumlahIzin = 0;
    jumlahSakit = 0;
    jumlahTidakHadir = 0;

    for (var status in statusAbsensi.values) {
      switch (status) {
        case "Hadir":
          jumlahHadir++;
          break;
        case "Izin":
          jumlahIzin++;
          break;
        case "Sakit":
          jumlahSakit++;
          break;
        case "Tidak Hadir":
          jumlahTidakHadir++;
          break;
      }
    }
  }

  // ================= LOAD DATA (SINGLE QUERY OPTIMIZATION) =================
  Future<void> loadData() async {
    try {
      setState(() => loading = true);

      final today = DateTime.now().toIso8601String().split("T")[0];

      // 1. Load Santri berdasarkan Marhalah
      final santriData = await supabase
          .from('santri')
          .select()
          .eq('marhalah', widget.marhalah)
          .order('nama_lengkap');

      santriList = List<Map<String, dynamic>>.from(santriData);

      if (santriList.isNotEmpty) {
        final List<int> santriIds =
            santriList.map((s) => s['id'] as int).toList();

        // 2. Fetch data absensi hari ini dalam 1 query saja
        final absensiData = await supabase
            .from('kehadiran_setoran')
            .select()
            .inFilter('santri_id', santriIds)
            .eq('tanggal', today);

        final Map<int, String> existingStatus = {};
        for (var item in absensiData) {
          existingStatus[item['santri_id']] = item['status'];
        }

        // Standard status default: "Hadir" jika belum ada catatan hari ini
        for (var s in santriList) {
          int id = s['id'];
          statusAbsensi[id] = existingStatus[id] ?? "Hadir";
        }
      }

      hitungStatistik();

      if (!mounted) return;
      setState(() => loading = false);
    } catch (e) {
      debugPrint("Error loadData: $e");
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= SIMPAN ABSENSI (BATCH UPSERT) =================
  Future<void> simpanAbsensi() async {
    try {
      setState(() => isSaving = true);
      final today = DateTime.now().toIso8601String().split("T")[0];

      // Susun data batch
      List<Map<String, dynamic>> payload = santriList.map((s) {
        int santriId = s['id'];
        return {
          'santri_id': santriId,
          'pembimbing_id': widget.idPembimbing,
          'tanggal': today,
          'status': statusAbsensi[santriId] ?? "Hadir",
        };
      }).toList();

      // Upsert sekaligus (Single Request)
      await supabase.from('kehadiran_setoran').upsert(
            payload,
            onConflict: 'santri_id, tanggal',
          );

      if (!mounted) return;
      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Absensi berhasil disimpan"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Absensi Setoran Santri"),
        backgroundColor: Colors.lime,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ================= CARD REKAPITULASI (BAGIAN ATAS) =================
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.green,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Rekap Kehadiran Hari Ini",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Jumlah Santri"),
                              Text(
                                "${santriList.length}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Hadir"),
                              Text(
                                "$jumlahHadir",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Izin"),
                              Text(
                                "$jumlahIzin",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Sakit"),
                              Text(
                                "$jumlahSakit",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Tidak Hadir"),
                              Text(
                                "$jumlahTidakHadir",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ================= LIST SANTRI =================
                Expanded(
                  child: santriList.isEmpty
                      ? const Center(
                          child: Text("Tidak ada santri di marhalah ini"),
                        )
                      : ListView.builder(
                          itemCount: santriList.length,
                          itemBuilder: (_, index) {
                            final s = santriList[index];
                            final int santriId = s['id'];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          child: Icon(Icons.person),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                s['nama_lengkap'] ?? '-',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Kelas ${s['kelas'] ?? '-'} • ${s['jenjang'] ?? '-'}",
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: statusAbsensi[santriId],
                                      decoration: const InputDecoration(
                                        labelText: "Status Kehadiran",
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: "Hadir",
                                          child: Text("Hadir"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Izin",
                                          child: Text("Izin"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Sakit",
                                          child: Text("Sakit"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Tidak Hadir",
                                          child: Text("Tidak Hadir"),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            statusAbsensi[santriId] = value;
                                            hitungStatistik();
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // ================= TOMBOL SIMPAN =================
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lime,
                      ),
                      onPressed: isSaving ? null : simpanAbsensi,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(
                              Icons.save,
                              color: Colors.black,
                            ),
                      label: Text(
                        isSaving ? "Menyimpan..." : "Simpan Absensi",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}