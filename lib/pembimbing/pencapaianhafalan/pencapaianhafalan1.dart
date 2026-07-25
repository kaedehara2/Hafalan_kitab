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
  State<PencapaianHafalan1Page> createState() => _PencapaianHafalan1PageState();
}

class _PencapaianHafalan1PageState extends State<PencapaianHafalan1Page> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> santriList = [];

  // ================= DATA AQIDATUL AWAM =================
  final List<String> bagianAqidatulAwam = [
    "AQ 1", "AQ 2", "AQ 3", "AQ 4", "AQ 5", "AQ 6", "AQ 7", "AQ 8",
    "AQ 9", "AQ 10", "AQ 11", "AQ 12", "AQ 13", "AQ 14", "AQ 15", "AQ 16",
    "AQ 17", "AQ 18", "AQ 19", "AQ 20", "AQ 21", "AQ 22", "AQ 23", "AQ 24",
    "AQ 25", "AQ 26", "AQ 27", "AQ 28"
  ];

  final Map<String, String> keteranganAqidatulAwam = {
    "AQ 1": "Bait 1 - 2 (Basmalah & Hamdalah)",
    "AQ 2": "Bait 3 - 4 (Shalawat & Salam)",
    "AQ 3": "Bait 5 - 6 (Sifat Wajib Allah)",
    "AQ 4": "Bait 7 - 8 (Sifat Mustahil & Jaiz)",
    "AQ 5": "Bait 9 - 10 (Sifat Rasulullah)",
    "AQ 6": "Bait 11 - 12 (Sifat Wajib & Jaiz Rasul)",
    "AQ 7": "Bait 13 - 14 (Nama-nama Rasul)",
    "AQ 8": "Bait 15 - 16 (Nama Rasul Lanjutan)",
    "AQ 9": "Bait 17 - 18 (Malaikat & Tugasnya)",
    "AQ 10": "Bait 19 - 20 (Kitab-kitab Allah)",
    "AQ 11": "Bait 21 - 22 (Sahabat & Keluarga Nabi)",
    "AQ 12": "Bait 23 - 24 (Putra-Putri Nabi)",
    "AQ 13": "Bait 25 - 26 (Nasab Nabi)",
    "AQ 14": "Bait 27 - 28 (Istri-istri Nabi)",
    "AQ 15": "Bait 29 - 30 (Paman & Bibi Nabi)",
    "AQ 16": "Bait 31 - 32 (Isra' Mi'raj)",
    "AQ 17": "Bait 33 - 34 (Kewajiban Shalat)",
    "AQ 18": "Bait 35 - 36 (Penutup & Doa)",
    "AQ 19": "Bait 37 - 38 (Lanjutan Penutup)",
    "AQ 20": "Bait 39 - 40 (Selesai Penutup)",
    "AQ 21": "Bait 41 - 42 (Tambahan Bait)",
    "AQ 22": "Bait 43 - 44 (Tambahan Bait)",
    "AQ 23": "Bait 45 - 46 (Tambahan Bait)",
    "AQ 24": "Bait 47 - 48 (Tambahan Bait)",
    "AQ 25": "Bait 49 - 50 (Tambahan Bait)",
    "AQ 26": "Bait 51 - 52 (Tambahan Bait)",
    "AQ 27": "Bait 53 - 54 (Tambahan Bait)",
    "AQ 28": "Bait 55 - 57 (Khatam Nadhom)",
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

        for (var bagian in bagianAqidatulAwam) {
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
          .eq('kitab', 'Aqidatul Awam');

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
            'kitab': 'Aqidatul Awam',
            'bagian': bagian.key,
            'status': bagian.value,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data hafalan Aqidatul Awam berhasil disimpan'),
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

    final bool isLargeColumn = bagianAqidatulAwam.length > 20;
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
                      'Kitab: Aqidatul Awam | ${widget.marhalah}',
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
                    ...bagianAqidatulAwam.map((bagian) {
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
                      ...bagianAqidatulAwam.map((bagian) {
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

            // Keterangan Bagian/Bait (Grid Layout Hemat Tempat)
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
              children: keteranganAqidatulAwam.entries.map((e) {
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
            ...bagianAqidatulAwam.map(
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
                ...bagianAqidatulAwam.map(
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