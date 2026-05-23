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
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> santriList = [];

  final List<String> bagianJurumiyah = [
    "Kalam (Muqoddimah)",
    "Bab I'rab",
    "Bab Ma'rifat Alamatil I'rabi",
    "Faslun Al-Mu'rabatu",
    "Bab Al-Af'ali",
    "Bab Marfuatil Asmai",
    "Bab Al-Fa'ili",
    "Bab Al-Maf'uladzi Lam Yusamma Failuhu",
    "Bab Al-Mubtada'i Wal-Khabari",
    "Bab Al-Awamili Ad-Dakhilati Alal Mubtada'i Wal-Khabari",
    "Bab An-Na'ti",
    "Bab Al-Athfi",
    "Bab At-Taukidi",
    "Bab Al-Badli",
    "Bab Manshubatil Asma'i",
    "Bab Al-Maf'uli Bihi",
    "Bab Al-Mashdari",
    "Bab Dzhorfiz Zamani Wa Dzhorfil Makani",
    "Bab Al-Hal",
    "Bab At-Tamyizi",
    "Bab Al-Istisna'i",
    "Bab La'",
    "Bab Al-Munada'",
    "Bab Al-Maf'uli Li Ajlih",
    "Bab Al-Maf'uli Ma'ahu",
    "Bab Al-Makhfudhati Minal Asma'i",
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

        for (var bagian in bagianJurumiyah) {
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
          .eq('kitab', 'Jurumiyah');

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
            'kitab': 'Jurumiyah',
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
        pageFormat: PdfPageFormat.a3.landscape,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'Pencapaian Hafalan Jurumiyah',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: [
                  'Nama Santri',
                  ...bagianJurumiyah,
                ],
                data: santriList.map((santri) {
                  String nama = santri['nama_lengkap'];

                  return [
                    nama,
                    ...bagianJurumiyah.map((bagian) {
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

          ...bagianJurumiyah.map(
            (bagian) => DataColumn(
              label: SizedBox(
                width: 120,
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

              ...bagianJurumiyah.map(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pencapaian Hafalan Jurumiyah',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
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