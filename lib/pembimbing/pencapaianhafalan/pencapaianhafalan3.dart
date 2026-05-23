import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PencapaianHafalan3Page extends StatefulWidget {
  final String marhalah;

  const PencapaianHafalan3Page({
    super.key,
    required this.marhalah,
  });

  @override
  State<PencapaianHafalan3Page> createState() =>
      _PencapaianHafalan3PageState();
}

class _PencapaianHafalan3PageState
    extends State<PencapaianHafalan3Page>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  late TabController _tabController;

  List<Map<String, dynamic>> santriList = [];

  bool isLoading = true;

  // =========================
  // NADZAM IMRITHI
  // =========================

  final List<String> bagianImrithi = [
    "Muqoddimah (Pendahuluan)",
    "Bab Al-Kalam (Kalimat/Ucapan)",
    "Bab Al-I'rab (Perubahan Akhir Kata)",
    "Bab Alamat Al-I'rab (Tanda-tanda I'rab)",
    "Bab Al-Fasl (Fasal tentang Mu'rab)",
    "Bab Al-Af'al (Kata Kerja/Fi'il)",
    "Bab Isim-Isim yang Marfu' (Dibaca Rafa')",
    "Bab Al-Fa'il (Pelaku/Subjek)",
    "Bab Na'ibul Fa'il (Pengganti Fa'il/Pasif)",
    "Bab Al-Mubtada' wa Al-Khabar (Subjek & Predikat Isim)",
    "Bab Kana wa Akhwatuha (Amil Pengubah Mubtada-Khabar)",
    "Bab Inna wa Akhwatuha",
    "Bab Zhanna wa Akhwatuha",
    "Bab At-Tabi' lil Marfu' (Na'at, Athaf, Taukid, Badal)",
    "Bab Isim-Isim yang Manshub (Dibaca Nashab)",
    "Bab Al-Mahfuzhat (Isim-Isim yang Dibaca Jer/Khofad)",
    "Khotimah (Penutup Kitab)",
  ];

  // =========================
  // NADZAM MAQSUD
  // =========================

  final List<String> bagianMaqsud = [
    "Muqoddimah (Pendahuluan)",
    "Bab Tsulatsi Mujarrad (Kata Kerja 3 Huruf Asli)",
    "Bab Tsulatsi Mazid (3 Huruf dengan Tambahan)",
    "Bab Ruba'i (Kata Kerja 4 Huruf Asli & Tambahannya)",
    "Bab Mulhaq Ruba'i",
    "Bab Shahih wa Ghair Shahih",
    "Bab Mudha'af",
    "Bab Mahmuz",
    "Bab Mu'tal",
    "Bab Lafif wa Mutadakhil",
    "Bab Idgham",
    "Bab Isim-Isim",
    "Khotimah (Penutup Kitab)",
  ];

  // =========================
  // CHECKLIST DATA
  // =========================

  Map<String, Map<String, bool>> checklistImrithi = {};

  Map<String, Map<String, bool>> checklistMaqsud = {};

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    getSantri();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =========================
  // GET SANTRI
  // =========================

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

        checklistImrithi[nama] = {};
        checklistMaqsud[nama] = {};

        for (var bagian in bagianImrithi) {
          checklistImrithi[nama]![bagian] = false;
        }

        for (var bagian in bagianMaqsud) {
          checklistMaqsud[nama]![bagian] = false;
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

  // =========================
  // LOAD CHECKLIST
  // =========================

  Future<void> loadChecklist() async {
    try {
      final response = await supabase
          .from('pencapaian_hafalan')
          .select()
          .eq('marhalah', widget.marhalah);

      for (var item in response) {
        String nama = item['nama_santri'];
        String kitab = item['kitab'];
        String bagian = item['bagian'];
        bool status = item['status'];

        // IMRITHI
        if (kitab == 'Nadzam Imrithi') {
          if (checklistImrithi.containsKey(nama)) {
            checklistImrithi[nama]![bagian] = status;
          }
        }

        // MAQSUD
        if (kitab == 'Nadzam Maqsud') {
          if (checklistMaqsud.containsKey(nama)) {
            checklistMaqsud[nama]![bagian] = status;
          }
        }
      }
    } catch (e) {
      debugPrint('Error load checklist: $e');
    }
  }

  // =========================
  // SIMPAN IMRITHI
  // =========================

  Future<void> simpanImrithi() async {
    try {
      for (var santri in checklistImrithi.entries) {
        String namaSantri = santri.key;

        for (var bagian in santri.value.entries) {
          await supabase.from('pencapaian_hafalan').upsert({
            'nama_santri': namaSantri,
            'marhalah': widget.marhalah,
            'kitab': 'Nadzam Imrithi',
            'bagian': bagian.key,
            'status': bagian.value,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Imrithi berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error simpan Imrithi: $e');
    }
  }

  // =========================
  // SIMPAN MAQSUD
  // =========================

  Future<void> simpanMaqsud() async {
    try {
      for (var santri in checklistMaqsud.entries) {
        String namaSantri = santri.key;

        for (var bagian in santri.value.entries) {
          await supabase.from('pencapaian_hafalan').upsert({
            'nama_santri': namaSantri,
            'marhalah': widget.marhalah,
            'kitab': 'Nadzam Maqsud',
            'bagian': bagian.key,
            'status': bagian.value,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Maqsud berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error simpan Maqsud: $e');
    }
  }

  // =========================
  // PDF
  // =========================

  Future<void> cetakPDF(
    String judul,
    List<String> bagianList,
    Map<String, Map<String, bool>> checklistData,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a3.landscape,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                judul,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: [
                  'Nama Santri',
                  ...bagianList,
                ],
                data: santriList.map((santri) {
                  String nama = santri['nama_lengkap'];

                  return [
                    nama,
                    ...bagianList.map((bagian) {
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

  // =========================
  // BUILD TABLE
  // =========================

  Widget buildTable({
    required List<String> bagianList,
    required Map<String, Map<String, bool>> checklistData,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(
          color: Colors.black12,
        ),
        headingRowColor: MaterialStateProperty.all(
          Colors.green.shade100,
        ),
        columns: [
          const DataColumn(
            label: SizedBox(
              width: 150,
              child: Text(
                'Nama Santri',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          ...bagianList.map(
            (bagian) => DataColumn(
              label: SizedBox(
                width: 150,
                child: Text(
                  bagian,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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

              ...bagianList.map(
                (bagian) => DataCell(
                  Checkbox(
                    value: checklistData[nama]![bagian],
                    onChanged: (value) {
                      setState(() {
                        checklistData[nama]![bagian] =
                            value ?? false;
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

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pencapaian Hafalan Marhalah 3',
        ),
        backgroundColor: Colors.green,

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Nadzam Imrithi',
            ),
            Tab(
              text: 'Nadzam Maqsud',
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              controller: _tabController,
              children: [

                // =====================
                // TAB IMRITHI
                // =====================

                Column(
                  children: [
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: simpanImrithi,
                              icon: const Icon(Icons.save),
                              label: const Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                cetakPDF(
                                  'Pencapaian Hafalan Nadzam Imrithi',
                                  bagianImrithi,
                                  checklistImrithi,
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Cetak PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
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
                        child: buildTable(
                          bagianList: bagianImrithi,
                          checklistData: checklistImrithi,
                        ),
                      ),
                    ),
                  ],
                ),

                // =====================
                // TAB MAQSUD
                // =====================

                Column(
                  children: [
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: simpanMaqsud,
                              icon: const Icon(Icons.save),
                              label: const Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                cetakPDF(
                                  'Pencapaian Hafalan Nadzam Maqsud',
                                  bagianMaqsud,
                                  checklistMaqsud,
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Cetak PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
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
                        child: buildTable(
                          bagianList: bagianMaqsud,
                          checklistData: checklistMaqsud,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}