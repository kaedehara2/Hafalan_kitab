import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatHafalanPage extends StatefulWidget {
  const RiwayatHafalanPage({super.key});

  @override
  State<RiwayatHafalanPage> createState() => _RiwayatHafalanPageState();
}

class _RiwayatHafalanPageState extends State<RiwayatHafalanPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;

  Map<String, List<Map<String, dynamic>>> groupedData = {};

  @override
  void initState() {
    super.initState();
    _initLocale();
  }

  Future<void> _initLocale() async {
    await initializeDateFormatting('id_ID', null);
    await fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    try {
      final response = await supabase
          .from('hafalan_santri')
          .select('''
            id,
            kitab,
            bagian_awal,
            bagian_akhir,
            status,
            tanggal,
            santri: santri_id (
              nama_lengkap
            )
          ''')
          .order('tanggal', ascending: false);

      final Map<String, List<Map<String, dynamic>>> temp = {};

      for (final item in response) {
        final tanggal = DateTime.parse(item['tanggal']);
        final key = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(tanggal);

        temp.putIfAbsent(key, () => []);
        temp[key]!.add(item);
      }

      setState(() {
        groupedData = temp;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error riwayat hafalan: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lime[400],
        automaticallyImplyLeading: false,
        title: const Text(
          'Riwayat Setoran Hafalan',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedData.isEmpty
              ? const Center(child: Text('Belum ada data setoran hafalan'))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: groupedData.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTable(entry.value),
                      ],
                    );
                  }).toList(),
                ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> data) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FixedColumnWidth(40),
        1: FlexColumnWidth(2), // Nama
        2: FlexColumnWidth(2), // Kitab
        3: FlexColumnWidth(3), // Hafalan
        4: FlexColumnWidth(2), // Status
      },
      children: [
        _tableHeader(),
        ...List.generate(data.length, (index) {
          final item = data[index];

          final nama = item['santri']?['nama_lengkap'] ?? '-';
          final kitab = item['kitab'] ?? '-';
          final hafalan =
              '${item['bagian_awal']} - ${item['bagian_akhir']}';
          final status = item['status'];

          return TableRow(
            children: [
              _cell('${index + 1}', isCenter: true),
              _cell(nama),
              _cell(kitab),
              _cell(hafalan),
              _cell(status),
            ],
          );
        }),
      ],
    );
  }

  TableRow _tableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[300]),
      children: const [
        Padding(
          padding: EdgeInsets.all(6),
          child: Center(
            child: Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(6),
          child: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(6),
          child: Text('Kitab', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(6),
          child: Text('Hafalan', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(6),
          child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _cell(String text, {bool isCenter = false}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: isCenter ? Center(child: Text(text)) : Text(text),
    );
  }
}