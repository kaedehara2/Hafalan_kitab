import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AbsensiPage extends StatefulWidget {
  final String marhalah;
  final String idPembimbing;

  const AbsensiPage({
    super.key,
    required this.marhalah,
    required this.idPembimbing,
  });

  @override
  State<AbsensiPage> createState() =>
      _AbsensiPageState();
}

class _AbsensiPageState
    extends State<AbsensiPage> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  List<Map<String, dynamic>> santri = [];

  // ================= STATUS ABSENSI =================
  Map<int, String> statusAbsensi = {};

  @override
  void initState() {
    super.initState();
    loadSantri();
  }

  // ================= LOAD SANTRI =================
  Future<void> loadSantri() async {
    try {
      final data = await supabase
          .from('santri')
          .select()
          .eq(
            'marhalah',
            widget.marhalah,
          )
          .order(
            'nama_lengkap',
          );

      santri =
          List<Map<String, dynamic>>
              .from(data);

      // Default semua hadir
      for (var item in santri) {
        statusAbsensi[item['id']] =
            "Hadir";
      }

      setState(() {
        loading = false;
      });

    } catch (e) {

      debugPrint(
        e.toString(),
      );

      setState(() {
        loading = false;
      });
    }
  }

  // ================= SIMPAN ABSENSI =================
  Future<void> simpanAbsensi() async {

    try {

      final today =
          DateTime.now()
              .toIso8601String()
              .split("T")[0];

      for (var item in santri) {

        final santriId =
            item['id'];

        final status =
            statusAbsensi[santriId] ??
                "Hadir";

       final cek = await supabase
    .from('kehadiran_setoran')
    .select()
    .eq('santri_id', santriId)
    .eq('pembimbing_id', widget.idPembimbing)
    .eq('tanggal', today)
    .maybeSingle();

if (cek == null) {

  await supabase
      .from('kehadiran_setoran')
      .insert({

    'santri_id': santriId,
    'pembimbing_id': widget.idPembimbing,
    'tanggal': today,
    'status': status,

  });

} else {

  await supabase
      .from('kehadiran_setoran')
      .update({

    'status': status,

  })
      .eq('id', cek['id']);

}
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Absensi berhasil disimpan",
          ),

          backgroundColor:
              Colors.green,
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            "Gagal menyimpan : $e",
          ),

          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Absensi Santri",
        ),

        backgroundColor:
            Colors.lime,

      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Column(

              children: [

                Expanded(

                  child:
                      ListView.builder(

                    itemCount:
                        santri.length,

                    itemBuilder:
                        (_, index) {

                      final s =
                          santri[index];

                      return Card(

                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        child:
                            Padding(

                          padding:
                              const EdgeInsets.all(
                                  16),

                          child:
                              Column(

                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Row(

                                children: [

                                  const CircleAvatar(

                                    child: Icon(
                                      Icons.person,
                                    ),
                                  ),

                                  const SizedBox(
                                      width: 12),

                                  Expanded(

                                    child:
                                        Column(

                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [

                                        Text(

                                          s['nama_lengkap'],

                                          style:
                                              const TextStyle(

                                            fontWeight:
                                                FontWeight.bold,

                                            fontSize:
                                                16,
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                4),

                                        Text(

                                          "Kelas ${s['kelas']} • ${s['jenjang']}",

                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                  height: 16),

                              DropdownButtonFormField<
                                      String>(

                                value:
                                    statusAbsensi[
                                        s['id']],

                                decoration:
                                    const InputDecoration(

                                  labelText:
                                      "Status Kehadiran",

                                  border:
                                      OutlineInputBorder(),
                                ),

                                items:
                                    const [

                                  DropdownMenuItem(

                                    value:
                                        "Hadir",

                                    child: Text(
                                      "Hadir",
                                    ),
                                  ),

                                  DropdownMenuItem(

                                    value:
                                        "Izin",

                                    child: Text(
                                      "Izin",
                                    ),
                                  ),

                                  DropdownMenuItem(

                                    value:
                                        "Sakit",

                                    child: Text(
                                      "Sakit",
                                    ),
                                  ),

                                  DropdownMenuItem(

                                    value:
                                        "Tidak Hadir",

                                    child: Text(
                                      "Tidak Hadir",
                                    ),
                                  ),
                                ],

                                onChanged:
                                    (value) {

                                  setState(() {

                                    statusAbsensi[
                                            s['id']] =
                                        value!;

                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(

                  padding:
                      const EdgeInsets.all(
                          16),

                  child: SizedBox(

                    width:
                        double.infinity,

                    height: 50,

                    child:
                        ElevatedButton.icon(

                      style:
                          ElevatedButton.styleFrom(

                        backgroundColor:
                            Colors.lime,

                      ),

                      onPressed:
                          simpanAbsensi,

                      icon:
                          const Icon(
                        Icons.save,
                        color:
                            Colors.black,
                      ),

                      label:
                          const Text(

                        "Simpan Absensi",

                        style:
                            TextStyle(

                          color:
                              Colors.black,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}