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

  // ======================================================
  // IMRITHI
  // ======================================================

  final Map<String, String> bagianImrithi = {

    "IM 1": "Muqoddimah",
    "IM 2": "Bab Al-Kalam",
    "IM 3": "Bab Al-I'rab",
    "IM 4": "Bab Ma'rifat Alamatil I'rabi",
    "IM 5": "Bab Al-Af'al",
    "IM 6": "Bab Al-Mu'rabat",
    "IM 7": "Bab Al-Nakirah Wal Ma'rifah",
    "IM 8": "Bab Al-Marfu'at minal Asma'",
    "IM 9": "Bab Al-Fa'il",
    "IM 10": "Bab Al-Naib 'an Al-Fa'il",
    "IM 11": "Bab Al-Mubtada' wal Khabar",
    "IM 12": "Bab Kana wa Akhwatuha",
    "IM 13": "Bab Inna wa Akhwatuha",
    "IM 14": "Bab Dzonna wa Akhwatuha",
    "IM 15": "Bab Al-Tawabi' (An-Na'ti)",
    "IM 16": "Bab Al-'Athfi",
    "IM 17": "Bab Al-Taukid",
    "IM 18": "Bab Al-Badal",
    "IM 19": "Bab Al-Manshubat minal Asma'",
    "IM 20": "Bab Al-Maf'ul bihi",
    "IM 21": "Bab Al-Mashdar",
    "IM 22": "Bab Dzhorf Zaman wa Dzhorf Makan",
    "IM 23": "Bab Al-Hal",
    "IM 24": "Bab Al-Tamyiz",
    "IM 25": "Bab Al-Istitsna'",
    "IM 26": "Bab Al-Laa",
    "IM 27": "Bab Al-Munada",
    "IM 28": "Bab Al-Maf'ul li Ajlih",
    "IM 29": "Bab Al-Maf'ul Ma'ah",
    "IM 30": "Bab Al-Makhfudhat minal Asma'",
    "IM 31": "Khotimah",
  };

  // ======================================================
  // MAQSUD
  // ======================================================

  final Map<String, String> bagianMaqsud = {

    "MQ 1": "Muqoddimah",
    "MQ 2": "Bab Al-Tsulatsi Al-Mujarrad",
    "MQ 3": "Bab Al-Tsulatsi Al-Mazid",
    "MQ 4": "Bab Al-Ruba'i Wal Khumasi",
    "MQ 5": "Bab Shahih Wal Mudho'af",
    "MQ 6": "Bab Al-Mu'tal",
    "MQ 7": "Bab Al-Lafif Wal Mahmuz",
    "MQ 8": "Bab Tasrif Al-Af'al",
    "MQ 9": "Bab Al-Amr Wal Nahyi",
    "MQ 10": "Bab Isim Fai'l Wal Isim Maf'ul",
    "MQ 11": "Bab Isim Zaman Wal Makan",
    "MQ 12": "Bab Isim Alah",
    "MQ 13": "Bab Al-I'lal",
    "MQ 14": "Khotimah",
  };

  // ======================================================
  // CHECKLIST
  // ======================================================

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

  // ======================================================
  // GET SANTRI
  // ======================================================

  Future<void> getSantri() async {

    try {

      final response = await supabase
          .from('santri')
          .select()
          .eq('marhalah', widget.marhalah)
          .order('nama_lengkap');

      santriList =
          List<Map<String, dynamic>>.from(response);

      for (var santri in santriList) {

        String nama = santri['nama_lengkap'];

        checklistImrithi[nama] = {};
        checklistMaqsud[nama] = {};

        for (var kode in bagianImrithi.keys) {
          checklistImrithi[nama]![kode] = false;
        }

        for (var kode in bagianMaqsud.keys) {
          checklistMaqsud[nama]![kode] = false;
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

  // ======================================================
  // LOAD CHECKLIST
  // ======================================================

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

        if (kitab == 'Nadzam Imrithi') {

          if (checklistImrithi.containsKey(nama)) {

            checklistImrithi[nama]![bagian] =
                status;
          }
        }

        if (kitab == 'Nadzam Maqsud') {

          if (checklistMaqsud.containsKey(nama)) {

            checklistMaqsud[nama]![bagian] =
                status;
          }
        }
      }

    } catch (e) {

      debugPrint('Error load checklist: $e');
    }
  }

  // ======================================================
  // SIMPAN
  // ======================================================

  Future<void> simpanData({

    required String kitab,
    required Map<String, Map<String, bool>>
        checklistData,

  }) async {

    try {

      for (var santri in checklistData.entries) {

        String namaSantri = santri.key;

        for (var bagian in santri.value.entries) {

          await supabase
              .from('pencapaian_hafalan')
              .upsert({

            'nama_santri': namaSantri,
            'marhalah': widget.marhalah,
            'kitab': kitab,
            'bagian': bagian.key,
            'status': bagian.value,
          });
        }
      }

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content: Text(
              'Data $kitab berhasil disimpan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {

      debugPrint('Error simpan: $e');
    }
  }

  // ======================================================
  // CETAK PDF
  // ======================================================

  Future<void> cetakPDF({

    required String judul,
    required String kitab,
    required Map<String, String> bagianMap,
    required Map<String, Map<String, bool>>
        checklistData,

  }) async {

    final pdf = pw.Document();

    pdf.addPage(

      pw.MultiPage(

        pageFormat:
            PdfPageFormat.a3.landscape,

        build: (context) {

          return [

            pw.Text(

              judul,

              style: pw.TextStyle(
                fontSize: 20,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            // ==========================================
            // TABEL
            // ==========================================

            pw.Table.fromTextArray(

              cellAlignment:
                  pw.Alignment.center,

              headerStyle: pw.TextStyle(
                fontWeight:
                    pw.FontWeight.bold,
                fontSize: 9,
              ),

              cellStyle: const pw.TextStyle(
                fontSize: 8,
              ),

              headers: [

                'Nama',

                ...bagianMap.keys,
              ],

              data: santriList.map((santri) {

                String nama =
                    santri['nama_lengkap'];

                return [

                  nama,

                  ...bagianMap.keys.map((kode) {

                    return checklistData[nama]![kode] ==
                            true
                        ? '✓'
                        : '';

                  }).toList(),
                ];

              }).toList(),
            ),

            pw.SizedBox(height: 20),

            // ==========================================
            // KETERANGAN
            // ==========================================

            pw.Text(

              'Keterangan Singkatan',

              style: pw.TextStyle(
                fontWeight:
                    pw.FontWeight.bold,
                fontSize: 14,
              ),
            ),

            pw.SizedBox(height: 10),

            ...bagianMap.entries.map(

              (e) {

                return pw.Padding(

                  padding:
                      const pw.EdgeInsets.only(
                    bottom: 3,
                  ),

                  child: pw.Text(

                    '${e.key} : ${e.value}',

                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(

      onLayout: (format) async =>
          pdf.save(),
    );
  }

  // ======================================================
  // BUILD TABLE
  // ======================================================

  Widget buildTable({

    required Map<String, String> bagianMap,

    required Map<String, Map<String, bool>>
        checklistData,

  }) {

    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,

      child: DataTable(

        border: TableBorder.all(
          color: Colors.black12,
        ),

        headingRowColor:
            MaterialStateProperty.all(
          Colors.green.shade100,
        ),

        columns: [

          const DataColumn(

            label: SizedBox(

              width: 150,

              child: Text(

                'Nama Santri',

                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          ...bagianMap.keys.map(

            (kode) => DataColumn(

              label: SizedBox(

                width: 70,

                child: Text(

                  kode,

                  textAlign:
                      TextAlign.center,

                  style: const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],

        rows: santriList.map((santri) {

          String nama =
              santri['nama_lengkap'];

          return DataRow(

            cells: [

              DataCell(

                SizedBox(

                  width: 150,

                  child: Text(nama),
                ),
              ),

              ...bagianMap.keys.map(

                (kode) => DataCell(

                  Checkbox(

                    value:
                        checklistData[nama]![kode],

                    onChanged: (value) {

                      setState(() {

                        checklistData[nama]![kode] =
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

  // ======================================================
  // BUILD KETERANGAN
  // ======================================================

 Widget buildKeterangan(
  Map<String, String> bagianMap,
) {
  return Container(
    margin: const EdgeInsets.all(12),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),

    child: ExpansionTile(
      initiallyExpanded: false,

      title: const Text(
        'Keterangan Singkatan',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),

      children: [
        Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: bagianMap.entries.map(
              (e) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 8,
                  ),

                  child: Text(
                    '${e.key} : ${e.value}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ],
    ),
  );
}

  // ======================================================
  // BUILD
  // ======================================================

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
              child:
                  CircularProgressIndicator(),
            )

          : TabBarView(

              controller: _tabController,

              children: [

                // ======================================
                // TAB IMRITHI
                // ======================================

                Column(

                  children: [

                    const SizedBox(height: 10),

                    Padding(

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),

                      child: Row(

                        children: [

                          Expanded(

                            child:
                                ElevatedButton.icon(

                              onPressed: () {

                                simpanData(

                                  kitab:
                                      'Nadzam Imrithi',

                                  checklistData:
                                      checklistImrithi,
                                );
                              },

                              icon:
                                  const Icon(Icons.save),

                              label:
                                  const Text('Simpan'),

                              style:
                                  ElevatedButton.styleFrom(

                                backgroundColor:
                                    Colors.green,

                                foregroundColor:
                                    Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(

                            child:
                                ElevatedButton.icon(

                              onPressed: () {

                                cetakPDF(

                                  judul:
                                      'Pencapaian Hafalan Nadzam Imrithi',

                                  kitab:
                                      'Nadzam Imrithi',

                                  bagianMap:
                                      bagianImrithi,

                                  checklistData:
                                      checklistImrithi,
                                );
                              },

                              icon: const Icon(
                                Icons.picture_as_pdf,
                              ),

                              label:
                                  const Text('Cetak PDF'),

                              style:
                                  ElevatedButton.styleFrom(

                                backgroundColor:
                                    Colors.red,

                                foregroundColor:
                                    Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                              Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    Padding(
                      padding:
                          const EdgeInsets.all(12),

                      child: buildTable(
                        bagianMap:
                            bagianImrithi,

                        checklistData:
                            checklistImrithi,
                      ),
                    ),

                    buildKeterangan(
                      bagianImrithi,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
                  ],
                ),

                // ======================================
                // TAB MAQSUD
                // ======================================

                Column(

                  children: [

                    const SizedBox(height: 10),

                    Padding(

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),

                      child: Row(

                        children: [

                          Expanded(

                            child:
                                ElevatedButton.icon(

                              onPressed: () {

                                simpanData(

                                  kitab:
                                      'Nadzam Maqsud',

                                  checklistData:
                                      checklistMaqsud,
                                );
                              },

                              icon:
                                  const Icon(Icons.save),

                              label:
                                  const Text('Simpan'),

                              style:
                                  ElevatedButton.styleFrom(

                                backgroundColor:
                                    Colors.green,

                                foregroundColor:
                                    Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(

                            child:
                                ElevatedButton.icon(

                              onPressed: () {

                                cetakPDF(

                                  judul:
                                      'Pencapaian Hafalan Nadzam Maqsud',

                                  kitab:
                                      'Nadzam Maqsud',

                                  bagianMap:
                                      bagianMaqsud,

                                  checklistData:
                                      checklistMaqsud,
                                );
                              },

                              icon: const Icon(
                                Icons.picture_as_pdf,
                              ),

                              label:
                                  const Text('Cetak PDF'),

                              style:
                                  ElevatedButton.styleFrom(

                                backgroundColor:
                                    Colors.red,

                                foregroundColor:
                                    Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [

                          Padding(
                            padding:
                                const EdgeInsets.all(12),

                            child: buildTable(
                              bagianMap:
                                  bagianMaqsud,

                              checklistData:
                                  checklistMaqsud,
                            ),
                          ),

                          buildKeterangan(
                            bagianMaqsud,
                          ),

                          const SizedBox(height: 20),
                        ],
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