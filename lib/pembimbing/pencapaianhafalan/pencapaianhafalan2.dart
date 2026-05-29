import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class PencapaianHafalan2Page extends StatefulWidget {

  final String marhalah;

  const PencapaianHafalan2Page({
    super.key,
    required this.marhalah,
  });

  @override
  State<PencapaianHafalan2Page> createState() =>
      _PencapaianHafalan2PageState();
}

class _PencapaianHafalan2PageState
    extends State<PencapaianHafalan2Page> {

  final supabase =
      Supabase.instance.client;

  List<Map<String, dynamic>>
      santriList = [];

  // ================= SINGKATAN =================
  final List<String> kodeJurumiyah = [

    "JR 1",
    "JR 2",
    "JR 3",
    "JR 4",
    "JR 5",
    "JR 6",
    "JR 7",
    "JR 8",
    "JR 9",
    "JR 10",
    "JR 11",
    "JR 12",
    "JR 13",
    "JR 14",
    "JR 15",
    "JR 16",
    "JR 17",
    "JR 18",
    "JR 19",
    "JR 20",
    "JR 21",
    "JR 22",
    "JR 23",
    "JR 24",
    "JR 25",
    "JR 26",
  ];

  // ================= KEPANJANGAN =================
  final Map<String, String>
      detailJurumiyah = {

    "JR 1":
        "Kalam (Muqoddimah)",

    "JR 2":
        "Bab I'rab",

    "JR 3":
        "Bab Ma'rifat Alamatil I'rabi",

    "JR 4":
        "Faslun Al-Mu'rabatu",

    "JR 5":
        "Bab Al-Af'ali",

    "JR 6":
        "Bab Marfuatil Asmai",

    "JR 7":
        "Bab Al-Fa'ili",

    "JR 8":
        "Bab Al-Maf'uladzi Lam Yusamma Failuhu",

    "JR 9":
        "Bab Al-Mubtada'i Wal-Khabari",

    "JR 10":
        "Bab Al-Awamili Ad-Dakhilati Alal Mubtada'i Wal-Khabari",

    "JR 11":
        "Bab An-Na'ti",

    "JR 12":
        "Bab Al-Athfi",

    "JR 13":
        "Bab At-Taukidi",

    "JR 14":
        "Bab Al-Badli",

    "JR 15":
        "Bab Manshubatil Asma'i",

    "JR 16":
        "Bab Al-Maf'uli Bihi",

    "JR 17":
        "Bab Al-Mashdari",

    "JR 18":
        "Bab Dzhorfiz Zamani Wa Dzhorfil Makani",

    "JR 19":
        "Bab Al-Hal",

    "JR 20":
        "Bab At-Tamyizi",

    "JR 21":
        "Bab Al-Istisna'i",

    "JR 22":
        "Bab La'",

    "JR 23":
        "Bab Al-Munada'",

    "JR 24":
        "Bab Al-Maf'uli Li Ajlih",

    "JR 25":
        "Bab Al-Maf'uli Ma'ahu",

    "JR 26":
        "Bab Al-Makhfudhati Minal Asma'i",
  };

  Map<String, Map<String, bool>>
      checklistData = {};

  bool isLoading = true;

  @override
  void initState() {

    super.initState();

    getSantri();
  }

  // ================= GET SANTRI =================
  Future<void> getSantri() async {

    try {

      final response =
          await supabase

              .from('santri')

              .select()

              .eq(
                'marhalah',
                widget.marhalah,
              )

              .order(
                'nama_lengkap',
              );

      santriList =
          List<Map<String,
              dynamic>>.from(response);

      for (var santri
          in santriList) {

        String nama =
            santri['nama_lengkap'];

        checklistData[nama] = {};

        for (var kode
            in kodeJurumiyah) {

          checklistData[nama]![kode] =
              false;
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
  Future<void> loadChecklist() async {

    try {

      final response =
          await supabase

              .from(
                  'pencapaian_hafalan')

              .select()

              .eq(
                'marhalah',
                widget.marhalah,
              )

              .eq(
                'kitab',
                'Jurumiyah',
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

          checklistData[nama]![bagian] =
              status;
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
                'Jurumiyah',

            'bagian':
                bagian.key,

            'status':
                bagian.value,
          });
        }
      }

      if (mounted) {

        ScaffoldMessenger.of(context)
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

        ScaffoldMessenger.of(context)
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

  // ================= CETAK PDF =================
  Future<void> cetakPDF() async {

    final pdf = pw.Document();

    pdf.addPage(

      pw.MultiPage(

        pageFormat:
            PdfPageFormat.a3.landscape,

        build: (pw.Context context) {

          return [

            pw.Text(

              'Pencapaian Hafalan Jurumiyah',

              style: pw.TextStyle(

                fontSize: 20,

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

                fontSize: 9,
              ),

              cellStyle:
                  const pw.TextStyle(
                fontSize: 8,
              ),

              headers: [

                'Nama Santri',

                ...kodeJurumiyah,
              ],

              data:
                  santriList.map((santri) {

                String nama =
                    santri[
                        'nama_lengkap'];

                return [

                  nama,

                  ...kodeJurumiyah.map(

                    (kode) {

                      return checklistData[
                                      nama]![
                                  kode] ==
                              true

                          ? '✓'

                          : '';
                    },
                  ).toList(),
                ];

              }).toList(),
            ),

            pw.SizedBox(height: 25),

            // ================= KETERANGAN =================
            pw.Text(

              'Keterangan Singkatan:',

              style: pw.TextStyle(

                fontWeight:
                    pw.FontWeight.bold,

                fontSize: 14,
              ),
            ),

            pw.SizedBox(height: 10),

            ...kodeJurumiyah.map(

              (kode) {

                return pw.Padding(

                  padding:
                      const pw.EdgeInsets.only(
                    bottom: 4,
                  ),

                  child: pw.Text(

                    '$kode : ${detailJurumiyah[kode]}',

                    style:
                        const pw.TextStyle(
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

          ...kodeJurumiyah.map(

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

        rows: santriList.map(
          (santri) {

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

                ...kodeJurumiyah.map(

                  (kode) => DataCell(

                    Checkbox(

                      value:
                          checklistData[
                              nama]![kode],

                      onChanged:
                          (value) {

                        setState(() {

                          checklistData[
                                  nama]![
                              kode] =

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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Pencapaian Hafalan Jurumiyah',
        ),

        backgroundColor:
            Colors.green,
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Column(

              children: [

                const SizedBox(
                    height: 10),

                // ================= BUTTON =================
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

                          onPressed:
                              simpanChecklist,

                          icon: const Icon(
                            Icons.save,
                          ),

                          label:
                              const Text(
                            'Simpan',
                          ),

                          style:
                              ElevatedButton.styleFrom(

                            backgroundColor:
                                Colors.green,

                            foregroundColor:
                                Colors.white,

                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                          width: 10),

                      Expanded(

                        child:
                            ElevatedButton.icon(

                          onPressed:
                              cetakPDF,

                          icon: const Icon(
                            Icons.picture_as_pdf,
                          ),

                          label:
                              const Text(
                            'Cetak PDF',
                          ),

                          style:
                              ElevatedButton.styleFrom(

                            backgroundColor:
                                Colors.red,

                            foregroundColor:
                                Colors.white,

                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 12),

                // ================= KETERANGAN =================
                Expanded(

                  child: Padding(

                    padding:
                        const EdgeInsets.all(
                            12),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Expanded(
                          child: buildTable(),
                        ),

                        const SizedBox(
                            height: 16),

                        const Text(

                          'Keterangan Singkatan:',

                          style: TextStyle(

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                            height: 8),

                        Expanded(

                          child:
                              ListView.builder(

                            itemCount:
                                kodeJurumiyah
                                    .length,

                            itemBuilder:
                                (context,
                                    index) {

                              final kode =
                                  kodeJurumiyah[
                                      index];

                              return Padding(

                                padding:
                                    const EdgeInsets.only(
                                  bottom: 6,
                                ),

                                child: Text(

                                  '$kode : ${detailJurumiyah[kode]}',

                                  style:
                                      const TextStyle(
                                    fontSize:
                                        13,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}