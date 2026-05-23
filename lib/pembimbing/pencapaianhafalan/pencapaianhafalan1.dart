import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PencapaianHafalan1Page extends StatefulWidget {
  final String marhalah;

  const PencapaianHafalan1Page({
    super.key,
    required this.marhalah,
  });

  @override
  State<PencapaianHafalan1Page> createState() =>
      _PencapaianHafalan1PageState();
}

class _PencapaianHafalan1PageState
    extends State<PencapaianHafalan1Page> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> santriList = [];

  final List<String> bagianAwamil = [
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

  Map<String, Map<String, bool>> checklistData = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getSantri();
  }

  Future<void> getSantri() async {
    try {
      final response = await supabase
          .from('santri')
          .select()
          .eq('marhalah', widget.marhalah)
          .order('nama_lengkap');

      santriList = List<Map<String, dynamic>>.from(response);

      for (var santri in santriList) {
        String nama = santri['nama_lengkap'];

        checklistData[nama] = {};

        for (var bagian in bagianAwamil) {
          checklistData[nama]![bagian] = false;
        }
      }

      await loadChecklist();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error get santri: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadChecklist() async {
    try {
      final response = await supabase
          .from('pencapaian_hafalan')
          .select()
          .eq('marhalah', widget.marhalah)
          .eq('kitab', 'Awamil');

      for (var item in response) {
        String nama = item['nama_santri'];
        String bagian = item['bagian'];
        bool status = item['status'];

        if (checklistData.containsKey(nama)) {
          checklistData[nama]![bagian] = status;
        }
      }
    } catch (e) {
      debugPrint('Error load checklist: $e');
    }
  }

  Future<void> simpanChecklist() async {
    try {
      for (var santri in checklistData.entries) {
        String namaSantri = santri.key;

        for (var bagian in santri.value.entries) {
          await supabase.from('pencapaian_hafalan').upsert({
            'nama_santri': namaSantri,
            'marhalah': widget.marhalah,
            'kitab': 'Awamil',
            'bagian': bagian.key,
            'status': bagian.value,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error simpan checklist: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> cetakPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'Pencapaian Hafalan Awamil',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: [
                  'Nama Santri',
                  ...bagianAwamil,
                ],
                data: santriList.map((santri) {
                  String nama = santri['nama_lengkap'];

                  return [
                    nama,
                    ...bagianAwamil.map((bagian) {
                      return checklistData[nama]![bagian] == true
                          ? '✓'
                          : '';
                    }).toList(),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Widget buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(
          color: Colors.black12,
        ),
        columns: [
          const DataColumn(
            label: Text(
              'Nama Santri',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          ...bagianAwamil.map(
            (bagian) => DataColumn(
              label: SizedBox(
                width: 100,
                child: Text(
                  bagian,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
        rows: santriList.map((santri) {
          String nama = santri['nama_lengkap'];

          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: 150,
                  child: Text(nama),
                ),
              ),

              ...bagianAwamil.map(
                (bagian) => DataCell(
                  Checkbox(
                    value: checklistData[nama]![bagian],
                    onChanged: (value) {
                      setState(() {
                        checklistData[nama]![bagian] = value ?? false;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pencapaian Hafalan Awamil',
        ),
        backgroundColor: Colors.green,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: simpanChecklist,
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: cetakPDF,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Cetak PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: buildTable(),
                  ),
                ),
              ],
            ),
    );
  }
}