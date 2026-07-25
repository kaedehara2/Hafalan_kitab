import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PencapaianHafalan3Page extends StatefulWidget {
  final String marhalah;

  const PencapaianHafalan3Page({
    super.key,
    required this.marhalah,
  });

  @override
  State<PencapaianHafalan3Page> createState() => _PencapaianHafalan3PageState();
}

class _PencapaianHafalan3PageState extends State<PencapaianHafalan3Page> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> santriList = [];

  // Nama Kitab untuk Marhalah 3
  final String namaKitab = "Imriti"; // Ubah sesuai kitab Marhalah 3 jika berbeda

  // ================= DATA KITAB MARHALAH 3 =================
  final List<String> bagianKitab = [
    "IM 1", "IM 2", "IM 3", "IM 4", "IM 5", "IM 6", "IM 7", "IM 8",
    "IM 9", "IM 10", "IM 11", "IM 12", "IM 13", "IM 14", "IM 15", "IM 16",
    "IM 17", "IM 18", "IM 19", "IM 20", "IM 21", "IM 22", "IM 23", "IM 24",
    "IM 25", "IM 26"
  ];

  final Map<String, String> keteranganKitab = {
    "IM 1": "Muqaddimah",
    "IM 2": "Bab Al-I'rab",
    "IM 3": "Bab Al-Alamat",
    "IM 4": "Bab Al-Ma'rifah wat Nakirah",
    "IM 5": "Bab Al-Af'al",
    "IM 6": "Bab Al-Marfu'at",
    "IM 7": "Bab Al-Fa'il",
    "IM 8": "Bab Na'ibul Fa'il",
    "IM 9": "Bab Al-Mubtada' wal Khabar",
    "IM 10": "Bab Kana wa Akhawatuha",
    "IM 11": "Bab Inna wa Akhawatuha",
    "IM 12": "Bab Zhanna wa Akhawatuha",
    "IM 13": "Bab An-Na'at",
    "IM 14": "Bab Al-'Athaf",
    "IM 15": "Bab At-Taukid",
    "IM 16": "Bab Al-Badal",
    "IM 17": "Bab Al-Manshubat",
    "IM 18": "Bab Al-Maf'ul Bihi",
    "IM 19": "Bab Al-Mashdar",
    "IM 20": "Bab Dzharf az-Zaman wal Makan",
    "IM 21": "Bab Al-Hal",
    "IM 22": "Bab At-Tamyiz",
    "IM 23": "Bab Al-Istisna'",
    "IM 24": "Bab La",
    "IM 25": "Bab Al-Munada",
    "IM 26": "Bab Al-Makhfudhat",
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

        for (var bagian in bagianKitab) {
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

  // ================= LOAD CHECKLIST FROM SUPABASE =================
  Future<void> loadChecklist() async {
    try {
      final response = await supabase
          .from('pencapaian_hafalan')
          .select()
          .eq('marhalah', widget.marhalah)
          .eq('kitab', namaKitab);

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
            'kitab': namaKitab,
            'bagian': bagian.key,
            'status': bagian.value,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data hafalan $namaKitab berhasil disimpan'),
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

    final bool isLargeColumn = bagianKitab.length > 20;
    final double headerFontSize = isLargeColumn ? 7.0 : 9.0;
    final double cellFontSize = isLargeColumn ? 6.5 : 8.5;
    final double ketFontSize = isLargeColumn ? 6.5 : 7.5;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
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
                      'Kitab: $namaKitab | ${widget.marhalah}',
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
                          fontSize: headerFontSize,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    ...bagianKitab.map((bagian) {
                      return pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 6),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          bagian,
                          style: pw.TextStyle(
                            fontSize: headerFontSize,
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
                          style: pw.TextStyle(fontSize: cellFontSize),
                        ),
                      ),
                      ...bagianKitab.map((bagian) {
                        bool isChecked = checklistData[nama]?[bagian] ?? false;

                        return pw.Container(
                          height: 18,
                          alignment: pw.Alignment.center,
                          child: isChecked
                              ? pw.Text(
                                  'ꪜ', // Menggunakan simbol emoji ꪜ
                                  style: pw.TextStyle(
                                    font: fontTaiViet,
                                    fontSize: cellFontSize + 2,
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

            pw.SizedBox(height: 16),

            // Keterangan Bagian/Bab (Grid Layout Hemat Tempat)
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
              children: keteranganKitab.entries.map((e) {
                return pw.Container(
                  width: isLargeColumn ? 140 : 180,
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        '${e.key}: ',
                        style: pw.TextStyle(
                          fontSize: ketFontSize,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          e.value,
                          style: pw.TextStyle(fontSize: ketFontSize),
                          maxLines: 1,
                          overflow: pw.TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                );
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
            ...bagianKitab.map(
              (bagian) => DataColumn(
                label: SizedBox(
                  width: 55,
                  child: Text(
                    bagian,
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
                ...bagianKitab.map(
                  (bagian) => DataCell(
                    Center(
                      child: Checkbox(
                        value: checklistData[nama]![bagian],
                        onChanged: (value) {
                          setState(() {
                            checklistData[nama]![bagian] = value ?? false;
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