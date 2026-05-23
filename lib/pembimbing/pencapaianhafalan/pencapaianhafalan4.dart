import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PencapaianHafalan4Page extends StatefulWidget {
  final String marhalah;

  const PencapaianHafalan4Page({
    super.key,
    required this.marhalah,
  });

  @override
  State<PencapaianHafalan4Page> createState() =>
      _PencapaianHafalan4PageState();
}

class _PencapaianHafalan4PageState
    extends State<PencapaianHafalan4Page> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> santriList = [];

  bool isLoading = true;

  // =========================
  // NADZAM ALFIYAH
  // =========================

  final List<String> bagianAlfiyah = [
    "Muqoddimah (Pendahuluan)",
    "Al-Kalam wa Ma Yatafallafu Minhu",
    "Al-Mu'rab wa Al-Mabni",
    "Al-Ma'rifah wa Al-Nakirah",
    "Al-Dhamir",
    "Al-Alam",
    "Ismul Isyarah",
    "Al-Mawshul",
    "Al-Mu'arraf bi Al-Adat",
    "Al-Mubtada' wa Al-Khabar",
    "Kana wa Akhwatuha",
    "Al-Af'al Al-Muqarabah",
    "Inna wa Akhwatuha",
    "La Allati Linahyi Al-Jins",
    "Zhanna wa Akhwatuha",
    "A'lama wa Ara",
    "Al-Fa'il",
    "Al-Na'ib 'an Al-Fa'il",
    "Isytighal Al-Amil 'an Al-Ma'mul",
    "Al-Ta'addi wa Al-Luzum",
    "Al-Tanazu' fi Al-Amal",
    "Al-Mafa'il",
    "Al-Maf'ul Al-Muthlaq",
    "Al-Maf'ul Lahu",
    "Al-Maf'ul Fihi",
    "Al-Maf'ul Ma'ahu",
    "Al-Istitsna'",
    "Al-Hal",
    "Al-Tamyiz",
    "Al-Huruf Al-Jarr",
    "Al-Idhafah",
    "Al-Mudhaf ila Ya' Al-Mutakallim",
    "Imal Al-Mashdar",
    "Imal Ism Al-Fa'il",
    "Al-Abniyah Li-Asma' Al-Fa'ilin",
    "Al-Sifatus Musyabbahah",
    "Al-Ta'ajjub",
    "Ni'ma wa Bi'sa",
    "Af'alu Al-Tafdhil",
    "Al-Tawabi'",
    "Al-Na'at",
    "Al-Taukid",
    "Al-Athaf",
    "Al-Badal",
    "Al-Nida'",
    "Al-Ikhtishash",
    "Al-Tahdzir wa Al-Ighra'",
    "Asma' Al-Af'al wa Asma' Al-Aswat",
    "Al-Nun Al-Taukid",
    "Al-Mamnu' min Al-Sharf",
    "I'rab Al-Fi'il",
    "Al-Awwamil Al-Jazimah",
    "Al-Lawiyah",
    "Al-Amal bi Al-Adad",
    "Al-Kam wa Al-Ka'ayyin wa Al-Kadza",
    "Al-Hikayah",
    "Al-Tanwin Al-Mu'awwadh",
    "Al-Imalah",
    "Al-Tasghir",
    "Al-Nasab",
    "Al-Waqf",
    "Al-I'lal wa Al-Ibdal",
    "Fashl Ibdal Al-Waw wa Al-Ya' Alif",
    "Fashl Nuqila Al-Harakah",
    "Fashl Ibdal Al-Waw wa Al-Ya' Taa'",
    "Fashl Al-Ibdal min Huruf Shahihah",
    "Fashl fi Hadf Al-Waw",
    "Al-Idgham",
    "Khotimah (Penutup Kitab)",
  ];

  // =========================
  // CHECKLIST DATA
  // =========================

  Map<String, Map<String, bool>> checklistData = {};

  @override
  void initState() {
    super.initState();
    getSantri();
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

        checklistData[nama] = {};

        for (var bagian in bagianAlfiyah) {
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

  // =========================
  // LOAD CHECKLIST
  // =========================

  Future<void> loadChecklist() async {
    try {
      final response = await supabase
          .from('pencapaian_hafalan')
          .select()
          .eq('marhalah', widget.marhalah)
          .eq('kitab', 'Nadzam Alfiyah');

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

  // =========================
  // SIMPAN
  // =========================

  Future<void> simpanChecklist() async {
    try {
      for (var santri in checklistData.entries) {
        String namaSantri = santri.key;

        for (var bagian in santri.value.entries) {
          await supabase.from('pencapaian_hafalan').upsert({
            'nama_santri': namaSantri,
            'marhalah': widget.marhalah,
            'kitab': 'Nadzam Alfiyah',
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

  // =========================
  // CETAK PDF
  // =========================

  Future<void> cetakPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,

        build: (pw.Context context) {
          return [
            pw.Text(
              'Pencapaian Hafalan Nadzam Alfiyah',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Table.fromTextArray(
              headers: [
                'Nama Santri',
                ...bagianAlfiyah,
              ],

              data: santriList.map((santri) {
                String nama = santri['nama_lengkap'];

                return [
                  nama,

                  ...bagianAlfiyah.map((bagian) {
                    return checklistData[nama]![bagian] == true
                        ? '✓'
                        : '';
                  }).toList(),
                ];
              }).toList(),
            ),
          ];
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

          ...bagianAlfiyah.map(
            (bagian) => DataColumn(
              label: SizedBox(
                width: 170,
                child: Text(
                  bagian,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
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

              ...bagianAlfiyah.map(
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
          'Pencapaian Hafalan Nadzam Alfiyah',
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