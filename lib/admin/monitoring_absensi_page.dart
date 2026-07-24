import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonitoringAbsensiPage extends StatefulWidget {
  const MonitoringAbsensiPage({super.key});

  @override
  State<MonitoringAbsensiPage> createState() => _MonitoringAbsensiPageState();
}

class _MonitoringAbsensiPageState extends State<MonitoringAbsensiPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> groupedData = {};

  @override
  void initState() {
    super.initState();
    fetchAllAbsensi();
  }

  // ================= FETCH ALL DATA ABSENSI & GROUP BY MARHALAH =================
  Future<void> fetchAllAbsensi() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Ambil data kehadiran setoran beserta relasi ke tabel santri (kolom nama_lengkap & marhalah)
      final response = await supabase
          .from('kehadiran_setoran')
          .select('*, santri!inner(nama_lengkap, marhalah)')
          .order('tanggal', ascending: false);

      final List<dynamic> rawList = response as List<dynamic>;

      // Kelompokkan data berdasarkan 'marhalah' dari santri
      final Map<String, List<Map<String, dynamic>>> tempGroup = {};

      for (var item in rawList) {
        final santriData = item['santri'] as Map<String, dynamic>?;
        final marhalah =
            santriData?['marhalah']?.toString().trim() ?? 'Tanpa Marhalah';

        if (!tempGroup.containsKey(marhalah)) {
          tempGroup[marhalah] = [];
        }
        tempGroup[marhalah]!.add(Map<String, dynamic>.from(item));
      }

      setState(() {
        groupedData = tempGroup;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetch all absensi: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Urutkan kunci marhalah (Marhalah 1, Marhalah 2, dst)
    final sortedMarhalahKeys = groupedData.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Monitoring Absensi'),
        backgroundColor: Colors.lime[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAllAbsensi,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sortedMarhalahKeys.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada data rekapan absensi yang dicatat.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchAllAbsensi,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: sortedMarhalahKeys.length,
                    itemBuilder: (context, index) {
                      final marhalah = sortedMarhalahKeys[index];
                      final listAbsensi = groupedData[marhalah] ?? [];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Judul Marhalah
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.lime[700],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Text(
                                marhalah.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            // Tabel Data Absensi
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.lime[50],
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'No',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Nama Santri',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Tanggal',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Status Kehadiran',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                                rows: List<DataRow>.generate(
                                  listAbsensi.length,
                                  (i) {
                                    final row = listAbsensi[i];
                                    final namaSantri =
                                        row['santri']?['nama_lengkap'] ?? '-';
                                    final tanggal = row['tanggal'] ?? '-';
                                    final status = row['status'] ?? '-';

                                    final bool isHadir = status
                                            .toString()
                                            .toLowerCase() ==
                                        'hadir';

                                    return DataRow(
                                      cells: [
                                        DataCell(Text('${i + 1}')),
                                        DataCell(
                                          Text(
                                            namaSantri,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(tanggal.toString())),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isHadir
                                                  ? Colors.green[100]
                                                  : Colors.red[100],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              status,
                                              style: TextStyle(
                                                color: isHadir
                                                    ? Colors.green[900]
                                                    : Colors.red[900],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
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
                    },
                  ),
                ),
    );
  }
}