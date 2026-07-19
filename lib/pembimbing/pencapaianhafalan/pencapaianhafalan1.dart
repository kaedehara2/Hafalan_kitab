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

class _PencapaianHafalan1PageState extends State<PencapaianHafalan1Page>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController tabController;
  List<Map<String, dynamic>> santriList = [];

  // ================= DATA AWAMIL =================
  final List<String> bagianAwamil = [
    "AM 1", "AM 2", "AM 3", "AM 4", "AM 5", "AM 6", "AM 7", "AM 8",
    "AM 9", "AM 10", "AM 11", "AM 12", "AM 13", "AM 14", "AM 15", "AM 16",
  ];

  final Map<String, String> keteranganAwamil = {
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

  // ================= DATA BABUL MINAN =================
  final List<String> bagianBabulMinan = List.generate(35, (index) => "BM ${index + 1}");

  final Map<String, String> keteranganBabulMinan = {
    "BM 1": "Muqadimmah",
    "BM 2": "Pasal : Adapun artinya islam",
    "BM 3": "Pasal : Adapun yang dikata orang islam",
    "BM 4": "Pasal : Adapun artinya islam",
    "BM 5": "Pasal : Adapun artinya iman",
    "BM 6": "Pasal : Adapun artinya (Lafadz Tauhid)",
    "BM 7": "Pasal : Adapun rukun istinja",
    "BM 8": "Pasal : Adapun rukun air sembahyang",
    "BM 9": "Pasal : Adapun jikalau dapat hadast besar",
    "BM 10": "Pasal : Adapun syarat air sembahyang",
    "BM 11": "Pasal : Adapun yang membatalkan air sembahyang",
    "BM 12": "Pasal : Adapun apabila batal air sembahyang",
    "BM 13": "Pasal : Adapun jika dapat hadast besar",
    "BM 14": "Pasal : Adapun barang yang najis",
    "BM 15": "Pasal : Adapun membasuh najis",
    "BM 16": "Pasal : Adapun lain najis",
    "BM 17": "Pasal : Adapun sekurang-kurangnya haid",
    "BM 18": "Pasal : Adapun sekurang-kurangnya nifas",
    "BM 19": "Pasal : Adapun jikalau perempuan haid",
    "BM 20": "Pasal : Adapun sembahyang lima waktu",
    "BM 21": "Pasal : Adapun syarat sembahyang",
    "BM 22": "Pasal : Adapun rukun sembahyang",
    "BM 23": "Pasal : Adapun sembahyang jum'at",
    "BM 24": "Pasal : Adapun syaratnya diwaktu zuhur",
    "BM 25": "Pasal : Adapun sembahyang jenazah",
    "BM 26": "Pasal : Adapun zakat itu wajib",
    "BM 27": "Pasal : Adapun qadar zakat",
    "BM 28": "Pasal : Adapun zakat fitrah",
    "BM 29": "Pasal : Adapun itu zakat emas atau perak",
    "BM 30": "Pasal : Adapun puasa ramadan",
    "BM 31": "Pasal : Adapun syaratnya pula",
    "BM 32": "Pasal : Adapun pergi haji",
    "BM 33": "Pasal : Adapun pencaharian kehidupan",
    "BM 34": "Pasal : Adapun pertigahan syarah",
    "BM 35": "Khatimah (Penutup)",
  };

  // Struktur checklistData sekarang memisahkan antara Awamil dan Babul Minan
  // Map<NamaSantri, Map<NamaKitab, Map<Bagian/Bab, Status>>>
  Map<String, Map<String, Map<String, bool>>> checklistData = {};
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
          .eq('marhalah', widget.marhalah)
          .order('nama_lengkap');

      santriList = List<Map<String, dynamic>>.from(response);

      for (var santri in santriList) {
        String nama = santri['nama_lengkap'];
        checklistData[nama] = {
          'Awamil': {},
          'Babul Minan': {},
        };

        // Inisialisasi awal default false untuk Awamil
        for (var bagian in bagianAwamil) {
          checklistData[nama]!['Awamil']![bagian] = false;
        }

        // Inisialisasi awal default false untuk Babul Minan
        for (var bagian in bagianBabulMinan) {
          checklistData[nama]!['Babul Minan']![bagian] = false;
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
          .eq('marhalah', widget.marhalah);

      for (var item in response) {
        String nama = item['nama_santri'];
        String kitab = item['kitab']; // 'Awamil' atau 'Babul Minan'
        String bagian = item['bagian'];
        bool status = item['status'];

        if (checklistData.containsKey(nama) && checklistData[nama]!.containsKey(kitab)) {
          checklistData[nama]![kitab]![bagian] = status;
        }
      }
    } catch (e) {
      debugPrint('Error load checklist: $e');
    }
  }

  // ================= SIMPAN KE SUPABASE =================
  Future<void> simpanChecklist(String kitab) async {
    try {
      for (var santri in checklistData.entries) {
        String namaSantri = santri.key;
        var dataKitab = santri.value[kitab];

        if (dataKitab != null) {
          for (var bagian in dataKitab.entries) {
            await supabase.from('pencapaian_hafalan').upsert({
              'nama_santri': namaSantri,
              'marhalah': widget.marhalah,
              'kitab': kitab,
              'bagian': bagian.key,
              'status': bagian.value,
            });
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data hafalan $kitab berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error simpan checklist $kitab: $e');
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

  // ================= PDF GENERATOR =================
  Future<void> cetakPDF(String kitab, List<String> listBagian, Map<String, String> ketMap) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            pw.Text(
              'Pencapaian Hafalan $kitab',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),

            // ================= TABEL PDF =================
            pw.Table.fromTextArray(
              cellAlignment: pw.Alignment.center,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 6, // Diperkecil sedikit agar muat hingga 35 kolom BM
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 6,
              ),
              headers: [
                'Nama',
                ...listBagian,
              ],
              data: santriList.map((santri) {
                String nama = santri['nama_lengkap'];
                return [
                  nama,
                  ...listBagian.map((bagian) {
                    return checklistData[nama]![kitab]![bagian] == true ? '✓' : '';
                  }).toList(),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),

            // ================= KETERANGAN PDF =================
            pw.Text(
              'Keterangan:',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Wrap(
              spacing: 10,
              runSpacing: 4,
              children: ketMap.entries.map((e) {
                return pw.Container(
                  width: 180, // Membagi susunan keterangan agar hemat ruang kertas
                  child: pw.Text(
                    '${e.key} : ${e.value}',
                    style: const pw.TextStyle(fontSize: 7),
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
  Widget buildTable(String kitab, List<String> listBagian) {
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
            ...listBagian.map(
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
                ...listBagian.map(
                  (bagian) => DataCell(
                    Center(
                      child: Checkbox(
                        value: checklistData[nama]![kitab]![bagian],
                        onChanged: (value) {
                          setState(() {
                            checklistData[nama]![kitab]![bagian] = value ?? false;
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

  // ================= VIEW LAYOUT UNTUK SETIAP TAB =================
  Widget buildTabContent(String kitab, List<String> listBagian, Map<String, String> ketMap) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => simpanChecklist(kitab),
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
                  onPressed: () => cetakPDF(kitab, listBagian, ketMap),
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
            child: buildTable(kitab, listBagian),
          ),
        ),
      ],
    );
  }

  // ================= CORE UI build =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencapaian Hafalan Marhalah 1'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Awamil'),
            Tab(text: 'Babul Minan'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              controller: tabController,
              children: [
                // ================= TAB AWAMIL =================
                buildTabContent('Awamil', bagianAwamil, keteranganAwamil),

                // ================= TAB BABUL MINAN =================
                buildTabContent('Babul Minan', bagianBabulMinan, keteranganBabulMinan),
              ],
            ),
    );
  }
}