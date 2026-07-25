import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PencapaianHafalan2Page extends StatefulWidget {
  final String marhalah;

  const PencapaianHafalan2Page({
    super.key,
    required this.marhalah,
  });

  @override
  State<PencapaianHafalan2Page> createState() => _PencapaianHafalan2PageState();
}

class _PencapaianHafalan2PageState extends State<PencapaianHafalan2Page> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> santriList = [];

  // ================= DATA JURUMIHAH =================
  final List<String> bagianJurumiyah = [
    "JR 1", "JR 2", "JR 3", "JR 4", "JR 5", "JR 6", "JR 7", "JR 8",
    "JR 9", "JR 10", "JR 11", "JR 12", "JR 13", "JR 14", "JR 15", "JR 16",
    "JR 17", "JR 18", "JR 19", "JR 20", "JR 21", "JR 22", "JR 23", "JR 24",
    "JR 25", "JR 26"
  ];

  final Map<String, String> keteranganJurumiyah = {
    "JR 1": "Kalam (Muqoddimah)",
    "JR 2": "Bab I'rab",
    "JR 3": "Bab Ma'rifat Alamatil I'rabi",
    "JR 4": "Faslun Al-Mu'rabatu",
    "JR 5": "Bab Al-Af'ali",
    "JR 6": "Bab Marfuatil Asmai",
    "JR 7": "Bab Al-Fa'ili",
    "JR 8": "Bab Al-Maf'uladzi Lam Yusamma Failuhu",
    "JR 9": "Bab Al-Mubtada'i Wal-Khabari",
    "JR 10": "Bab Al-Awamili Ad-Dakhilati Alal Mubtada'i Wal-Khabari",
    "JR 11": "Bab An-Na'ti",
    "JR 12": "Bab Al-Athfi",
    "JR 13": "Bab At-Taukidi",
    "JR 14": "Bab Al-Badli",
    "JR 15": "Bab Manshubatil Asma'i",
    "JR 16": "Bab Al-Maf'uli Bihi",
    "JR 17": "Bab Al-Mashdari",
    "JR 18": "Bab Dzhorfiz Zamani Wa Dzhorfil Makani",
    "JR 19": "Bab Al-Hal",
    "JR 20": "Bab At-Tamyizi",
    "JR 21": "Bab Al-Istisna'i",
    "JR 22": "Bab La'",
    "JR 23": "Bab Al-Munada'",
    "JR 24": "Bab Al-Maf'uli Li Ajlih",
    "JR 25": "Bab Al-Maf'uli Ma'ahu",
    "JR 26": "Bab Al-Makhfudhati Minal Asma'i",
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

  // ================= LOAD CHECKLIST FROM SUPABASE =================
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

  // ================= SIMPAN KE SUPABASE =================
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
            content: Text('Data hafalan Jurumiyah berhasil disimpan'),
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

    final bool isLargeColumn = bagianJurumiyah.length > 20;
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
                      'Kitab: Jurumiyah | ${widget.marhalah}',
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
                    ...bagianJurumiyah.map((bagian) {
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
                      ...bagianJurumiyah.map((bagian) {
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
              children: keteranganJurumiyah.entries.map((e) {
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
            ...bagianJurumiyah.map(
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
                ...bagianJurumiyah.map(
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