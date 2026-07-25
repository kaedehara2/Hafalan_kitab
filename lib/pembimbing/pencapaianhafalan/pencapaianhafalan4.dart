import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PencapaianHafalan4Page extends StatefulWidget {
  final String marhalah;

  const PencapaianHafalan4Page({
    super.key,
    required this.marhalah,
  });

  @override
  State<PencapaianHafalan4Page> createState() => _PencapaianHafalan4PageState();
}

class _PencapaianHafalan4PageState extends State<PencapaianHafalan4Page> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> santriList = [];

  // ================= DATA ALFIYAH =================
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

  Map<String, Map<String, bool>> checklistData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getSantri();
  }

  // ================= GET SANTRI =================
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

  // ================= LOAD CHECKLIST FROM SUPABASE =================
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

  // ================= SIMPAN KE SUPABASE =================
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
            content: Text('Data hafalan Nadzam Alfiyah berhasil disimpan'),
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

  // ================= REVISED & IMPROVED PDF GENERATOR =================
  Future<void> cetakPDF() async {
    final pdf = pw.Document();

    // Memuat font khusus pendukung karakter Tai Viet "ꪜ"
    final fontTaiViet = await PdfGoogleFonts.notoSansTaiVietRegular();

    final listKeys = bagianAlfiyah.keys.toList();
    final bagian1 = listKeys.take(35).toList();
    final bagian2 = listKeys.skip(35).toList();

    // Fungsi pembantu membuat tabel halaman PDF
    pw.Widget buildPdfPageTable(
        String subJudul, List<String> listBagian) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header Dokumen
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LEMBAR VALIDASI PENCAPAIAN HAFALAN',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Kitab: Nadzam Alfiyah ($subJudul) | ${widget.marhalah}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Text(
                'Tanggal Cetak: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Divider(thickness: 1, color: PdfColors.grey400),
          pw.SizedBox(height: 10),

          // Tabel Utama
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey600,
              width: 0.5,
            ),
            children: [
              // Header Tabel
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE8F5E9), // Hijau Muda Halus
                ),
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        vertical: 6, horizontal: 4),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'Nama Santri',
                      style: pw.TextStyle(
                        fontSize: 7.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  ...listBagian.map((bagian) {
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 6),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        bagian,
                        style: pw.TextStyle(
                          fontSize: 6.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),

              // Baris Santri
              ...santriList.map((santri) {
                String nama = santri['nama_lengkap'];
                return pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(
                        nama,
                        style: const pw.TextStyle(fontSize: 6.5),
                      ),
                    ),
                    ...listBagian.map((bagian) {
                      bool isChecked = checklistData[nama]?[bagian] ?? false;

                      return pw.Container(
                        height: 16,
                        alignment: pw.Alignment.center,
                        child: isChecked
                            ? pw.Text(
                                'ꪜ', // Menggunakan simbol emoji ꪜ
                                style: pw.TextStyle(
                                  font: fontTaiViet,
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green800,
                                ),
                              )
                            : pw.Text(''),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ],
      );
    }

    // Halaman 1: AF 1 - AF 35
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          buildPdfPageTable('AF 1 - AF 35', bagian1),
        ],
      ),
    );

    // Halaman 2: AF 36 - AF 69 + Keterangan Singkatan
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          buildPdfPageTable('AF 36 - AF 69', bagian2),
          pw.SizedBox(height: 16),
          pw.Text(
            'Keterangan Bagian:',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 12,
            runSpacing: 4,
            children: bagianAlfiyah.entries.map((e) {
              return pw.Container(
                width: 140,
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      '${e.key}: ',
                      style: pw.TextStyle(
                        fontSize: 6.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        e.value,
                        style: const pw.TextStyle(fontSize: 6.5),
                        maxLines: 1,
                        overflow: pw.TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  // ================= REUSABLE DATA TABLE WIDGET =================
  Widget buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          border: TableBorder.all(
            color: Colors.black12,
          ),
          headingRowColor: WidgetStateProperty.all(
            Colors.green[100],
          ),
          columns: [
            const DataColumn(
              label: SizedBox(
                width: 140,
                child: Text(
                  'Nama Santri',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ...bagianAlfiyah.keys.map(
              (kode) => DataColumn(
                label: SizedBox(
                  width: 55,
                  child: Text(
                    kode,
                    textAlign: TextAlign.center,
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
                    width: 140,
                    child: Text(nama),
                  ),
                ),
                ...bagianAlfiyah.keys.map(
                  (kode) => DataCell(
                    Center(
                      child: Checkbox(
                        value: checklistData[nama]![kode],
                        onChanged: (value) {
                          setState(() {
                            checklistData[nama]![kode] = value ?? false;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ================= CORE UI build =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pencapaian Hafalan ${widget.marhalah}'),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
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