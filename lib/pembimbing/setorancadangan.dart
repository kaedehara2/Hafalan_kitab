import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SetoranCadanganPage extends StatefulWidget {

  final String username;

  const SetoranCadanganPage({
    super.key,
    required this.username,
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

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  // ================= FETCH DATA =================
  Future<void> fetchData() async {

    setState(() {
      loading = true;
    });

    try {

      final santri = await supabase
          .from('santri')
          .select('id, nama_lengkap')
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
                dynamic>>.from(pembimbing);

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
                      Map<String, dynamic>>(

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

                    items: santriList.map(
                      (santri) {

                        return DropdownMenuItem(
                          value: santri,

                          child: Text(
                            santri[
                                'nama_lengkap'],
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: (value) {

                      setState(() {
                        selectedSantri =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                      height: 20),

                  // ================= PILIH PEMBIMBING =================
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
                      Map<String, dynamic>>(

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

                    onChanged: (value) {

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
                              Text(kitab),
                        );
                      },
                    ).toList(),

                    onChanged: (value) {

                      setState(() {
                        selectedKitab =
                            value;
                      });
                    },
                  ),
                ],
              ),
            ),
    );
  }
}