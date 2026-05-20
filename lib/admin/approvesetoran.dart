import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApproveKhatamanPage extends StatefulWidget {
  const ApproveKhatamanPage({super.key});

  @override
  State<ApproveKhatamanPage> createState() =>
      _ApproveKhatamanPageState();
}

class _ApproveKhatamanPageState
    extends State<ApproveKhatamanPage>
    with SingleTickerProviderStateMixin {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  late TabController tabController;

  // ================= DATA PER MARHALAH =================
  List<Map<String, dynamic>>
      marhalah1 = [];

  List<Map<String, dynamic>>
      marhalah2 = [];

  List<Map<String, dynamic>>
      marhalah3 = [];

  List<Map<String, dynamic>>
      marhalah4 = [];

  @override
  void initState() {
    super.initState();

    tabController =
        TabController(length: 4, vsync: this);

    fetchDataKhataman();
  }

  // ================= FETCH DATA =================
  Future<void>
      fetchDataKhataman() async {

    setState(() {
      loading = true;
    });

    try {

      final response = await supabase
          .from('setoran_khataman')
          .select('''
            id,
            kitab,
            status,
            catatan_admin,
            tanggal_pengajuan,
            tanggal_setoran,
            jadwal_setoran,
            santri (
              nama_lengkap,
              kelas,
              marhalah
            )
          ''')
          .order(
            'tanggal_pengajuan',
            ascending: false,
          );

      List<Map<String, dynamic>>
          data =
          List<Map<String,
              dynamic>>.from(response);

      marhalah1 = data.where((item) {

        final santri =
            item['santri'];

        return santri != null &&
            santri['marhalah'] ==
                'Marhalah 1';

      }).toList();

      marhalah2 = data.where((item) {

        final santri =
            item['santri'];

        return santri != null &&
            santri['marhalah'] ==
                'Marhalah 2';

      }).toList();

      marhalah3 = data.where((item) {

        final santri =
            item['santri'];

        return santri != null &&
            santri['marhalah'] ==
                'Marhalah 3';

      }).toList();

      marhalah4 = data.where((item) {

        final santri =
            item['santri'];

        return santri != null &&
            santri['marhalah'] ==
                'Marhalah 4';

      }).toList();

      if (!mounted) return;

      setState(() {
        loading = false;
      });

    } catch (e) {

      if (!mounted) return;

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

  // ================= JADWALKAN =================
  Future<void> jadwalkanSetoran(
    dynamic id,
  ) async {

    DateTime? selectedDate;

    showDialog(

      context: context,

      builder: (context) {

        return StatefulBuilder(
          builder: (context, setStateDialog) {

            return AlertDialog(

              title: const Text(
                'Jadwalkan Setoran',
              ),

              content: Column(

                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  Container(

                    width: double.infinity,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),

                    decoration: BoxDecoration(

                      border: Border.all(
                        color: Colors.grey,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),

                    child: Text(

                      selectedDate == null
                          ? 'Pilih tanggal setoran'
                          : DateFormat(
                              'EEEE, dd MMMM yyyy',
                              'id_ID',
                            ).format(
                              selectedDate!,
                            ),

                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 16),

                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton.icon(

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange,
                      ),

                      onPressed: () async {

                        final picked =
                            await showDatePicker(

                          context: context,

                          initialDate:
                              DateTime.now(),

                          firstDate:
                              DateTime.now(),

                          lastDate:
                              DateTime(2030),
                        );

                        if (picked != null) {

                          setStateDialog(() {
                            selectedDate = picked;
                          });
                        }
                      },

                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      ),

                      label: const Text(
                        'Pilih Tanggal',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              actions: [

                TextButton(

                  onPressed: () {

                    Navigator.pop(
                        context);
                  },

                  child: const Text(
                    'Batal',
                  ),
                ),

                ElevatedButton(

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                  ),

                  onPressed: () async {

                    if (selectedDate ==
                        null) {

                      ScaffoldMessenger.of(
                              this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tanggal wajib dipilih',
                          ),
                        ),
                      );

                      return;
                    }

                    try {

                      await supabase
                          .from(
                              'setoran_khataman')
                          .update({

                        'jadwal_setoran':
                            selectedDate!
                                .toIso8601String(),

                      }).eq(
                        'id',
                        id,
                      );

                      Navigator.pop(
                          context);

                      ScaffoldMessenger.of(
                              this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Jadwal berhasil disimpan',
                          ),
                        ),
                      );

                      fetchDataKhataman();

                    } catch (e) {

                      ScaffoldMessenger.of(
                              this.context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Gagal menyimpan jadwal: $e',
                          ),
                        ),
                      );
                    }
                  },

                  child: const Text(
                    'Simpan',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= APPROVE =================
  Future<void> approveKhataman(
    dynamic id,
  ) async {

    try {

      await supabase
          .from('setoran_khataman')
          .update({

        'status': 'disetujui',

        'tanggal_approve':
            DateTime.now()
                .toIso8601String(),

      }).eq(
        'id',
        id,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Setoran berhasil disetujui',
          ),
        ),
      );

      fetchDataKhataman();

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal approve: $e',
          ),
        ),
      );
    }
  }

  // ================= TOLAK =================
  Future<void> tolakKhataman(
    dynamic id,
  ) async {

    final TextEditingController
        catatanController =
            TextEditingController();

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            'Tolak Setoran',
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              const Text(
                'Masukkan alasan atau catatan admin',
              ),

              const SizedBox(
                  height: 16),

              TextField(

                controller:
                    catatanController,

                maxLines: 3,

                decoration:
                    InputDecoration(

                  hintText:
                      'Contoh: Hafalan belum lengkap',

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            12),
                  ),
                ),
              ),
            ],
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                    context);
              },

              child:
                  const Text(
                'Batal',
              ),
            ),

            ElevatedButton(

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),

              onPressed:
                  () async {

                try {

                  await supabase
                      .from(
                          'setoran_khataman')
                      .update({

                    'status':
                        'ditolak',

                    'catatan_admin':
                        catatanController
                            .text,

                    'tanggal_approve':
                        DateTime.now()
                            .toIso8601String(),

                  }).eq(
                    'id',
                    id,
                  );

                  Navigator.pop(
                      context);

                  ScaffoldMessenger.of(
                          this.context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Setoran ditolak',
                      ),
                    ),
                  );

                  fetchDataKhataman();

                } catch (e) {

                  ScaffoldMessenger.of(
                          this.context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        'Gagal menolak: $e',
                      ),
                    ),
                  );
                }
              },

              child:
                  const Text(
                'Tolak',
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= WARNA STATUS =================
  Color getStatusColor(
      String status) {

    switch (status) {

      case 'disetujui':
        return Colors.green;

      case 'ditolak':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  // ================= BUILD LIST =================
  Widget buildListKhataman(
    List<Map<String, dynamic>>
        dataKhataman,
  ) {

    if (dataKhataman.isEmpty) {

      return const Center(
        child: Text(
          'Belum ada pengajuan',
        ),
      );
    }

    return RefreshIndicator(

      onRefresh:
          fetchDataKhataman,

      child: ListView.builder(

        padding:
            const EdgeInsets.all(
                16),

        itemCount:
            dataKhataman.length,

        itemBuilder:
            (context, index) {

          final item =
              dataKhataman[index];

          final santri =
              item['santri'];

          final status =
              item['status'] ??
                  'pending';

          return Container(

            margin:
                const EdgeInsets.only(
                    bottom: 16),

            padding:
                const EdgeInsets.all(
                    16),

            decoration:
                BoxDecoration(

              color:
                  Colors.white,

              borderRadius:
                  BorderRadius.circular(
                      18),

              boxShadow: [

                BoxShadow(

                  color:
                      Colors.black12,

                  blurRadius:
                      6,

                  offset:
                      const Offset(
                          0,
                          3),
                ),
              ],
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                // ================= HEADER =================
                Row(

                  children: [

                    CircleAvatar(

                      backgroundColor:
                          Colors
                              .lime[300],

                      child:
                          const Icon(
                        Icons
                            .menu_book,

                        color:
                            Colors.black,
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

                            santri[
                                    'nama_lengkap'] ??
                                '-',

                            style:
                                const TextStyle(

                              fontSize:
                                  16,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(
                            '${santri['kelas']} • ${santri['marhalah']}',
                          ),
                        ],
                      ),
                    ),

                    Container(

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            12,
                        vertical:
                            6,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            getStatusColor(
                          status,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),

                      child: Text(

                        status
                            .toUpperCase(),

                        style:
                            const TextStyle(

                          color:
                              Colors.white,

                          fontWeight:
                              FontWeight.bold,

                          fontSize:
                              12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 18),

                // ================= DETAIL =================
                buildItemDetail(
                  'Kitab',
                  item['kitab'] ??
                      '-',
                ),

                buildItemDetail(
                  'Tanggal Pengajuan',

                  DateFormat(
                          'dd MMM yyyy')
                      .format(
                    DateTime.parse(
                      item[
                          'tanggal_pengajuan'],
                    ),
                  ),
                ),

                if (item[
                        'jadwal_setoran'] !=
                    null)

                  buildItemDetail(

                    'Jadwal Setoran',

                    DateFormat(
                            'dd MMM yyyy')
                        .format(
                      DateTime.parse(
                        item[
                            'jadwal_setoran'],
                      ),
                    ),
                  ),

                if (item[
                        'tanggal_setoran'] !=
                    null)

                  buildItemDetail(

                    'Tanggal Khatam',

                    DateFormat(
                            'dd MMM yyyy')
                        .format(
                      DateTime.parse(
                        item[
                            'tanggal_setoran'],
                      ),
                    ),
                  ),

                if (item[
                            'catatan_admin'] !=
                        null &&
                    item[
                            'catatan_admin']
                        .toString()
                        .isNotEmpty)

                  Container(

                    margin:
                        const EdgeInsets.only(
                            top: 12),

                    padding:
                        const EdgeInsets.all(
                            12),

                    decoration:
                        BoxDecoration(

                      color:
                          Colors.red[50],

                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),

                    child: Row(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        const Icon(
                          Icons.info,
                          color:
                              Colors.red,
                        ),

                        const SizedBox(
                            width:
                                10),

                        Expanded(

                          child:
                              Text(

                            item[
                                'catatan_admin'],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(
                    height: 20),

                // ================= BUTTON =================
                if (status ==
                    'pending')

                  Column(

                    children: [

                      SizedBox(

                        width: double.infinity,

                        child:
                            ElevatedButton.icon(

                          style:
                              ElevatedButton.styleFrom(

                            backgroundColor:
                                Colors.orange,
                          ),

                          onPressed:
                              () {

                            jadwalkanSetoran(
                              item[
                                  'id'],
                            );
                          },

                          icon:
                              const Icon(
                            Icons
                                .calendar_month,
                            color:
                                Colors.white,
                          ),

                          label:
                              const Text(
                            'Jadwalkan Setoran Khataman',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 12),

                      Row(

                        children: [

                          Expanded(

                            child:
                                ElevatedButton.icon(

                              style:
                                  ElevatedButton.styleFrom(

                                backgroundColor:
                                    Colors.green,
                              ),

                              onPressed:
                                  () {

                                approveKhataman(
                                  item[
                                      'id'],
                                );
                              },

                              icon:
                                  const Icon(
                                Icons
                                    .check,
                                color:
                                    Colors.white,
                              ),

                              label:
                                  const Text(
                                'Approve',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                              width:
                                  12),

                          Expanded(

                            child:
                                ElevatedButton.icon(

                              style:
                                  ElevatedButton.styleFrom(

                                backgroundColor:
                                    Colors.red,
                              ),

                              onPressed:
                                  () {

                                tolakKhataman(
                                  item[
                                      'id'],
                                );
                              },

                              icon:
                                  const Icon(
                                Icons
                                    .close,
                                color:
                                    Colors.white,
                              ),

                              label:
                                  const Text(
                                'Tolak',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[200],

      appBar: AppBar(

        title: const Text(
          'Approve Khataman',
        ),

        backgroundColor:
            Colors.lime[400],

        bottom: TabBar(

          controller:
              tabController,

          isScrollable: true,

          labelColor:
              Colors.black,

          tabs: const [

            Tab(
              text:
                  'Marhalah 1',
            ),

            Tab(
              text:
                  'Marhalah 2',
            ),

            Tab(
              text:
                  'Marhalah 3',
            ),

            Tab(
              text:
                  'Marhalah 4',
            ),
          ],
        ),
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : TabBarView(

              controller:
                  tabController,

              children: [

                buildListKhataman(
                  marhalah1,
                ),

                buildListKhataman(
                  marhalah2,
                ),

                buildListKhataman(
                  marhalah3,
                ),

                buildListKhataman(
                  marhalah4,
                ),
              ],
            ),
    );
  }

  // ================= ITEM DETAIL =================
  Widget buildItemDetail(
    String title,
    String value,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
              bottom: 10),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(

            width: 140,

            child: Text(

              title,

              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}