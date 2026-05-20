import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SetoranCadanganPage extends StatefulWidget {
  final String username;
  final String marhalah;

  const SetoranCadanganPage({
    super.key,
    required this.username,
    required this.marhalah,
  });

  @override
  State<SetoranCadanganPage> createState() =>
      _SetoranCadanganPageState();
}

class _SetoranCadanganPageState
    extends State<SetoranCadanganPage> {
  final supabase =
      Supabase.instance.client;

  bool loading = true;

  // ================= DATA =================
  List<Map<String, dynamic>>
      santriList = [];

  List<Map<String, dynamic>>
      pembimbingList = [];

  Map<String, dynamic>?
      selectedSantri;

  Map<String, dynamic>?
      selectedPembimbing;

  // ================= KITAB =================
  String? selectedKitab;

  final List<String> kitabList = [
    'Awamil',
    'Babul Minan',
    'Qoidah Shorfiyah',
    'Jurumiyah',
    'Nadhom Imrithi',
    'Nadhom Maqsud',
    'Nadham Alfiyah Ibn Malik',
  ];

  // ================= HAFALAN =================
  final TextEditingController
      bagianController =
      TextEditingController();

  // ================= PENILAIAN =================
  String? penilaian;

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  @override
  void dispose() {
    bagianController.dispose();
    super.dispose();
  }

  // ================= FETCH DATA =================
  Future<void> fetchData() async {
    setState(() {
      loading = true;
    });

    try {
      final santri = await supabase
          .from('santri')
          .select('id, nama_lengkap, marhalah')
         // .eq('marhalah', widget.marhalah)
          .order('nama_lengkap');

      final pembimbing = await supabase
          .from('pembimbing')
          .select('id, username')
          .order('username');

      if (!mounted) return;

      setState(() {
        santriList =
            List<Map<String,
                dynamic>>.from(santri);

        pembimbingList =
            List<Map<String,
                dynamic>>.from(
              pembimbing,
            );

        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil data: $e',
          ),
        ),
      );
    }
  }

  // ================= SIMPAN SETORAN =================
  Future<void> simpanSetoranCadangan() async {
    if (selectedSantri == null ||
        selectedPembimbing == null ||
        selectedKitab == null ||
        bagianController.text.isEmpty ||
        penilaian == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi semua data terlebih dahulu',
          ),
        ),
      );
      return;
    }

    try {
      await supabase
          .from('hafalan_santri')
          .insert({
        'santri_id':
            selectedSantri!['id'],

        'kitab': selectedKitab,

        'bagian':
            bagianController.text,

        'bagian_awal':
            bagianController.text,

        'bagian_akhir':
            bagianController.text,

        'status': penilaian,

        // ================= PEMBIMBING ASLI =================
        'pembimbing_input':
            widget.username,

        // ================= PEMBIMBING PENGGANTI =================
        'pembimbing_pengganti':
            selectedPembimbing![
                'username'],

        // ================= SETORAN CADANGAN =================
        'is_setoran_cadangan':
            true,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.green,
          content: Text(
            'Setoran cadangan berhasil disimpan',
          ),
        ),
      );

      // ================= RESET FORM =================
      setState(() {
        selectedSantri = null;
        selectedPembimbing = null;
        selectedKitab = null;
        penilaian = null;

        bagianController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan setoran: $e',
          ),
        ),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[200],

      appBar: AppBar(
        backgroundColor:
            Colors.lime[400],

        title: const Text(
          'Setoran Cadangan',
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                      16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  // ================= PILIH SANTRI =================
                  const Text(
                    'Pilih Santri',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  DropdownButtonFormField<
                      Map<String,
                          dynamic>>(
                    value:
                        selectedSantri,

                    decoration:
                        InputDecoration(
                      filled: true,
                      fillColor:
                          Colors.white,

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                14),
                      ),
                    ),

                    items:
                        santriList.map(
                      (santri) {
                        return DropdownMenuItem(
                          value:
                              santri,

                          child: Text(
                          '${santri['nama_lengkap']} (${santri['marhalah']})',
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: (
                      value,
                    ) {
                      setState(() {
                        selectedSantri =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                      height: 20),

                  // ================= PEMBIMBING PENGGANTI =================
                  const Text(
                    'Pembimbing Pengganti',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  DropdownButtonFormField<
                      Map<String,
                          dynamic>>(
                    value:
                        selectedPembimbing,

                    decoration:
                        InputDecoration(
                      filled: true,
                      fillColor:
                          Colors.white,

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                14),
                      ),
                    ),

                    items:
                        pembimbingList.map(
                      (pembimbing) {
                        return DropdownMenuItem(
                          value:
                              pembimbing,

                          child: Text(
                            pembimbing[
                                'username'],
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: (
                      value,
                    ) {
                      setState(() {
                        selectedPembimbing =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                      height: 20),

                  // ================= PILIH KITAB =================
                  const Text(
                    'Pilih Kitab',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  DropdownButtonFormField<
                      String>(
                    value:
                        selectedKitab,

                    decoration:
                        InputDecoration(
                      filled: true,
                      fillColor:
                          Colors.white,

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                14),
                      ),
                    ),

                    items:
                        kitabList.map(
                      (kitab) {
                        return DropdownMenuItem(
                          value:
                              kitab,

                          child:
                              Text(
                            kitab,
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: (
                      value,
                    ) {
                      setState(() {
                        selectedKitab =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                      height: 20),

                  // ================= HAFALAN =================
                  const Text(
                    'Bagian Hafalan',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  TextFormField(
                    controller:
                        bagianController,

                    maxLines: 3,

                    decoration:
                        InputDecoration(
                      hintText:
                          'Contoh:\nBab Kalam - Bab I\'rab',

                      filled: true,

                      fillColor:
                          Colors.white,

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                14),
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  // ================= PENILAIAN =================
                  const Text(
                    'Penilaian',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  Card(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),

                    child: Column(
                      children: [
                        RadioListTile(
                          title:
                              const Text(
                            'Lancar',
                          ),

                          value:
                              'Lancar',

                          groupValue:
                              penilaian,

                          activeColor:
                              Colors
                                  .lime[700],

                          onChanged: (
                            value,
                          ) {
                            setState(() {
                              penilaian =
                                  value;
                            });
                          },
                        ),

                        RadioListTile(
                          title:
                              const Text(
                            'Kurang Lancar',
                          ),

                          value:
                              'Kurang Lancar',

                          groupValue:
                              penilaian,

                          activeColor:
                              Colors
                                  .lime[700],

                          onChanged: (
                            value,
                          ) {
                            setState(() {
                              penilaian =
                                  value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 30),

                  // ================= BUTTON =================
                  SizedBox(
                    width:
                        double.infinity,

                    height: 55,

                    child:
                        ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors
                                .lime[400],

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                      ),

                      onPressed:
                          simpanSetoranCadangan,

                      child:
                          const Text(
                        'Simpan Setoran Cadangan',

                        style:
                            TextStyle(
                          color:
                              Colors.black,

                          fontWeight:
                              FontWeight.bold,

                          fontSize:
                              16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}