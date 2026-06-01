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
  // SINGKATAN ALFIYAH
  // =========================

  final Map<String, String> bagianAlfiyah = {
    "AF 1": "Muqoddimah (Pendahuluan)",
    "AF 2": "Al-Kalam wa Ma Yatafallafu Minhu",
    "AF 3": "Al-Mu'rab wa Al-Mabni",
    "AF 4": "Al-Ma'rifah wa Al-Nakirah",
    "AF 5": "Al-Dhamir",
    "AF 6": "Al-Alam",
    "AF 7": "Ismul Isyarah",
    "AF 8": "Al-Mawshul",
    "AF 9": "Al-Mu'arraf bi Al-Adat",
    "AF 10": "Al-Mubtada' wa Al-Khabar",
    "AF 11": "Kana wa Akhwatuha",
    "AF 12": "Al-Af'al Al-Muqarabah",
    "AF 13": "Inna wa Akhwatuha",
    "AF 14": "La Allati Linahyi Al-Jins",
    "AF 15": "Zhanna wa Akhwatuha",
    "AF 16": "A'lama wa Ara",
    "AF 17": "Al-Fa'il",
    "AF 18": "Al-Na'ib 'an Al-Fa'il",
    "AF 19": "Isytighal Al-Amil 'an Al-Ma'mul",
    "AF 20": "Al-Ta'addi wa Al-Luzum",
    "AF 21": "Al-Tanazu' fi Al-Amal",
    "AF 22": "Al-Mafa'il",
    "AF 23": "Al-Maf'ul Al-Muthlaq",
    "AF 24": "Al-Maf'ul Lahu",
    "AF 25": "Al-Maf'ul Fihi",
    "AF 26": "Al-Maf'ul Ma'ahu",
    "AF 27": "Al-Institsna'",
    "AF 28": "Al-Hal",
    "AF 29": "Al-Tamyiz",
    "AF 30": "Al-Huruf Al-Jarr",
    "AF 31": "Al-Idhafah",
    "AF 32": "Al-Mudhaf ila Ya' Al-Mutakallim",
    "AF 33": "Imal Al-Mashdar",
    "AF 34": "Imal Ism Al-Fa'il",
    "AF 35": "Al-Abniyah Li-Asma' Al-Fa'ilin",
    "AF 36": "Al-Sifatus Musyabbahah",
    "AF 37": "Al-Ta'ajjub",
    "AF 38": "Ni'ma wa Bi'sa",
    "AF 39": "Af'alu Al-Tafdhil",
    "AF 40": "Al-Tawabi'",
    "AF 41": "Al-Na'at",
    "AF 42": "Al-Taukid",
    "AF 43": "Al-Athaf",
    "AF 44": "Al-Badal",
    "AF 45": "Al-Nida'",
    "AF 46": "Al-Ikhtishash",
    "AF 47": "Al-Tahdzir wa Al-Ighra'",
    "AF 48": "Asma' Al-Af'al wa Asma' Al-Aswat",
    "AF 49": "Al-Nun Al-Taukid",
    "AF 50": "Al-Mamnu' min Al-Sharf",
    "AF 51": "I'rab Al-Fi'il",
    "AF 52": "Al-Awwamil Al-Jazimah",
    "AF 53": "Al-Lawiyah",
    "AF 54": "Al-Amal bi Al-Adad",
    "AF 55": "Al-Kam wa Al-Ka'ayyin wa Al-Kadza",
    "AF 56": "Al-Hikayah",
    "AF 57": "Al-Tanwin Al-Mu'awwadh",
    "AF 58": "Al-Imalah",
    "AF 59": "Al-Tasghir",
    "AF 60": "Al-Nasab",
    "AF 61": "Al-Waqf",
    "AF 62": "Al-I'lal wa Al-Ibdal",
    "AF 63": "Fashl Ibdal Al-Waw wa Al-Ya' Alif",
    "AF 64": "Fashl Nuqila Al-Harakah",
    "AF 65": "Fashl Ibdal Al-Waw wa Al-Ya' Taa'",
    "AF 66": "Fashl Al-Ibdal min Huruf Shahihah",
    "AF 67": "Fashl fi Hadf Al-Waw",
    "AF 68": "Al-Idgham",
    "AF 69": "Khotimah (Penutup Kitab)",
  };

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

        for (var kode in bagianAlfiyah.keys) {
          checklistData[nama]![kode] = false;
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

  final bagian1 =
      bagianAlfiyah.keys.take(35).toList();

  final bagian2 =
      bagianAlfiyah.keys.skip(35).toList();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a3.landscape,

      build: (context) => [

        pw.Text(
          'Pencapaian Hafalan Nadzam Alfiyah (AF1 - AF35)',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 15),

        pw.Table.fromTextArray(

          cellAlignment:
              pw.Alignment.center,

          headerStyle: pw.TextStyle(
            fontSize: 6,
            fontWeight:
                pw.FontWeight.bold,
          ),

          cellStyle:
              const pw.TextStyle(
            fontSize: 6,
          ),

          headers: [

            'Nama',

            ...bagian1.map(
              (e) =>
                  e.replaceAll('AF ', ''),
            ),
          ],

          data: santriList.map((santri) {

            final nama =
                santri['nama_lengkap'];

            return [

              nama,

              ...bagian1.map((kode) {

                return checklistData[nama]![kode] ==
                        true
                    ? '✓'
                    : '';
              }),
            ];
          }).toList(),
        ),
      ],
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a3.landscape,

      build: (context) => [

        pw.Text(
          'Pencapaian Hafalan Nadzam Alfiyah (AF36 - AF69)',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 15),

        pw.Table.fromTextArray(

          cellAlignment:
              pw.Alignment.center,

          headerStyle: pw.TextStyle(
            fontSize: 6,
            fontWeight:
                pw.FontWeight.bold,
          ),

          cellStyle:
              const pw.TextStyle(
            fontSize: 6,
          ),

          headers: [

            'Nama',

            ...bagian2.map(
              (e) =>
                  e.replaceAll('AF ', ''),
            ),
          ],

          data: santriList.map((santri) {

            final nama =
                santri['nama_lengkap'];

            return [

              nama,

              ...bagian2.map((kode) {

                return checklistData[nama]![kode] ==
                        true
                    ? '✓'
                    : '';
              }),
            ];
          }).toList(),
        ),

        pw.SizedBox(height: 25),

        pw.Text(
          'Keterangan Singkatan',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 10),

        ...bagianAlfiyah.entries.map(
          (e) => pw.Padding(
            padding:
                const pw.EdgeInsets.only(
              bottom: 3,
            ),
            child: pw.Text(
              '${e.key} : ${e.value}',
              style:
                  const pw.TextStyle(
                fontSize: 8,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async =>
        pdf.save(),
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

          ...bagianAlfiyah.keys.map(
            (kode) => DataColumn(
              label: SizedBox(
                width: 70,
                child: Text(
                  kode,
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

              ...bagianAlfiyah.keys.map(
                (kode) => DataCell(
                  Checkbox(
                    value: checklistData[nama]![kode],

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

  // =========================
  // BUILD KETERANGAN
  // =========================

  Widget buildKeterangan() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keterangan Singkatan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          ...bagianAlfiyah.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${e.key} : ${e.value}',
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
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
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: buildTable(),
                      ),

                      buildKeterangan(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}