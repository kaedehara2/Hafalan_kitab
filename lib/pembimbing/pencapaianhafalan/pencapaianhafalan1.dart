import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
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
    extends State<PencapaianHafalan1Page>
    with SingleTickerProviderStateMixin {

  final supabase =
      Supabase.instance.client;

  late TabController tabController;

  List<Map<String, dynamic>>
      santriList = [];

  // ================= AWAMIL =================
  final List<String> bagianAwamil = [

    "AM 1",
    "AM 2",
    "AM 3",
    "AM 4",
    "AM 5",
    "AM 6",
    "AM 7",
    "AM 8",
    "AM 9",
    "AM 10",
    "AM 11",
    "AM 12",
    "AM 13",
    "AM 14",
    "AM 15",
    "AM 16",
  ];

  // ================= KETERANGAN =================
  final Map<String, String>
      keteranganAwamil = {

    "AM 1": "Muqadimmah",
    "AM 2": "Warna ke 1",
    "AM 3": "Warna ke 2",
    "AM 4": "Warna ke 3",
    "AM 5": "Warna ke 4",
    "AM 6": "Warna ke 5",
    "AM 7": "Warna ke 6",
    "AM 8": "Warna ke 7",
    "AM 9": "Warna ke 8",
    "AM 10": "Warna ke 9",
    "AM 11": "Warna ke 10",
    "AM 12": "Warna ke 11",
    "AM 13": "Warna ke 12",
    "AM 14": "Warna ke 13",
    "AM 15": "Qiyâsi",
    "AM 16": "Ma'nawi",
  };

  Map<String, Map<String, bool>>
      checklistData = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 2,
      vsync: this,
    );

    getSantri();
  }

  // ================= GET SANTRI =================
  Future<void> getSantri() async {

    try {

      final response = await supabase

          .from('santri')

          .select()

          .eq(
            'marhalah',
            widget.marhalah,
          )

          .order('nama_lengkap');

      santriList =
          List<Map<String,
              dynamic>>.from(response);

      for (var santri
          in santriList) {

        String nama =
            santri['nama_lengkap'];

        checklistData[nama] = {};

        for (var bagian
            in bagianAwamil) {

          checklistData[nama]![
              bagian] = false;
        }
      }

      await loadChecklist();

      setState(() {
        isLoading = false;
      });

    } catch (e) {

      debugPrint(
        'Error get santri: $e',
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  // ================= LOAD CHECKLIST =================
  Future<void>
      loadChecklist() async {

    try {

      final response = await supabase

          .from(
              'pencapaian_hafalan')

          .select()

          .eq(
            'marhalah',
            widget.marhalah,
          )

          .eq(
            'kitab',
            'Awamil',
          );

      for (var item in response) {

        String nama =
            item['nama_santri'];

        String bagian =
            item['bagian'];

        bool status =
            item['status'];

        if (checklistData
            .containsKey(nama)) {

          checklistData[nama]![
              bagian] = status;
        }
      }

    } catch (e) {

      debugPrint(
        'Error load checklist: $e',
      );
    }
  }

  // ================= SIMPAN =================
  Future<void>
      simpanChecklist() async {

    try {

      for (var santri
          in checklistData.entries) {

        String namaSantri =
            santri.key;

        for (var bagian
            in santri.value.entries) {

          await supabase

              .from(
                  'pencapaian_hafalan')

              .upsert({

            'nama_santri':
                namaSantri,

            'marhalah':
                widget.marhalah,

            'kitab':
                'Awamil',

            'bagian':
                bagian.key,

            'status':
                bagian.value,
          });
        }
      }

      if (mounted) {

        ScaffoldMessenger.of(
                context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              'Data berhasil disimpan',
            ),

            backgroundColor:
                Colors.green,
          ),
        );
      }

    } catch (e) {

      debugPrint(
        'Error simpan checklist: $e',
      );

      if (mounted) {

        ScaffoldMessenger.of(
                context)
            .showSnackBar(

          SnackBar(

            content: Text(
              'Gagal menyimpan data: $e',
            ),

            backgroundColor:
                Colors.red,
          ),
        );
      }
    }
  }

  // ================= PDF =================
  Future<void> cetakPDF() async {

    final pdf = pw.Document();

    pdf.addPage(

      pw.MultiPage(

        pageFormat:
            PdfPageFormat.a4.landscape,

        build:
            (pw.Context context) {

          return [

            pw.Text(

              'Pencapaian Hafalan Awamil',

              style: pw.TextStyle(

                fontSize: 18,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            // ================= TABEL =================
            pw.Table.fromTextArray(

              cellAlignment:
                  pw.Alignment.center,

              headerStyle:
                  pw.TextStyle(

                fontWeight:
                    pw.FontWeight.bold,

                fontSize: 8,
              ),

              cellStyle:
                  const pw.TextStyle(

                fontSize: 7,
              ),

              headers: [

                'Nama',

                ...bagianAwamil,
              ],

              data:
                  santriList.map(

                (santri) {

                  String nama =
                      santri[
                          'nama_lengkap'];

                  return [

                    nama,

                    ...bagianAwamil
                        .map(

                      (bagian) {

                        return checklistData[
                                        nama]![
                                    bagian] ==
                                true

                            ? '✓'

                            : '';
                      },
                    ).toList(),
                  ];
                },
              ).toList(),
            ),

            pw.SizedBox(height: 20),

            // ================= KETERANGAN =================
            pw.Text(

              'Keterangan:',

              style: pw.TextStyle(

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            ...keteranganAwamil.entries
                .map(

              (e) {

                return pw.Padding(

                  padding:
                      const pw.EdgeInsets
                          .only(
                    bottom: 2,
                  ),

                  child: pw.Text(

                    '${e.key} : ${e.value}',

                    style:
                        const pw.TextStyle(
                      fontSize: 9,
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

      onLayout:
          (format) async =>
              pdf.save(),
    );
  }

  // ================= TABLE =================
  Widget buildTable() {

    return SingleChildScrollView(

      scrollDirection:
          Axis.horizontal,

      child: DataTable(

        border: TableBorder.all(
          color: Colors.black12,
        ),

        headingRowColor:
            WidgetStateProperty.all(
          Colors.green[100],
        ),

        columns: [

          const DataColumn(

            label: SizedBox(

              width: 140,

              child: Text(

                'Nama Santri',

                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          ...bagianAwamil.map(

            (bagian) => DataColumn(

              label: SizedBox(

                width: 60,

                child: Text(

                  bagian,

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],

        rows: santriList.map(

          (santri) {

            String nama =
                santri[
                    'nama_lengkap'];

            return DataRow(

              cells: [

                DataCell(

                  SizedBox(

                    width: 140,

                    child: Text(
                      nama,
                    ),
                  ),
                ),

                ...bagianAwamil.map(

                  (bagian) => DataCell(

                    Checkbox(

                      value:
                          checklistData[
                                  nama]![
                              bagian],

                      onChanged:
                          (value) {

                        setState(() {

                          checklistData[
                                      nama]![
                                  bagian] =
                              value ??
                                  false;
                        });
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }

  // ================= TAB BABUL MINAN =================
  Widget buildBabulMinan() {

    return const Center(

      child: Text(

        'Tab Babul Minan\nDesain Menyusul',

        textAlign: TextAlign.center,

        style: TextStyle(
          fontSize: 18,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Pencapaian Hafalan Marhalah 1',
        ),

        backgroundColor:
            Colors.green,

        bottom: TabBar(

          controller:
              tabController,

          tabs: const [

            Tab(
              text: 'Awamil',
            ),

            Tab(
              text: 'Babul Minan',
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

              controller:
                  tabController,

              children: [

                // ================= TAB AWAMIL =================
                Column(

                  children: [

                    const SizedBox(
                        height: 10),

                    Padding(

                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                      ),

                      child: Row(

                        children: [

                          Expanded(

                            child:
                                ElevatedButton
                                    .icon(

                              onPressed:
                                  simpanChecklist,

                              icon:
                                  const Icon(
                                Icons.save,
                              ),

                              label:
                                  const Text(
                                'Simpan',
                              ),

                              style:
                                  ElevatedButton
                                      .styleFrom(

                                backgroundColor:
                                    Colors.green,

                                foregroundColor:
                                    Colors.white,

                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical:
                                      14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                              width: 10),

                          Expanded(

                            child:
                                ElevatedButton
                                    .icon(

                              onPressed:
                                  cetakPDF,

                              icon:
                                  const Icon(
                                Icons
                                    .picture_as_pdf,
                              ),

                              label:
                                  const Text(
                                'Cetak PDF',
                              ),

                              style:
                                  ElevatedButton
                                      .styleFrom(

                                backgroundColor:
                                    Colors.red,

                                foregroundColor:
                                    Colors.white,

                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical:
                                      14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    Expanded(

                      child: Padding(

                        padding:
                            const EdgeInsets
                                .all(12),

                        child:
                            buildTable(),
                      ),
                    ),
                  ],
                ),

                // ================= TAB BABUL MINAN =================
                buildBabulMinan(),
              ],
            ),
    );
  }
}