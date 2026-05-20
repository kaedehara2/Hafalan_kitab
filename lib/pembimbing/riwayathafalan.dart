import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatHafalanPage extends StatefulWidget {
  final String username;

  const RiwayatHafalanPage({
    super.key,
    required this.username,
  });

  @override
  State<RiwayatHafalanPage> createState() =>
      _RiwayatHafalanPageState();
}

class _RiwayatHafalanPageState
    extends State<RiwayatHafalanPage>
    with SingleTickerProviderStateMixin {

  final supabase =
      Supabase.instance.client;

  bool isLoading = true;

  late TabController tabController;

  // ================= RIWAYAT NORMAL =================
  Map<String, List<Map<String, dynamic>>>
      groupedNormal = {};

  // ================= RIWAYAT CADANGAN =================
  Map<String, List<Map<String, dynamic>>>
      groupedCadangan = {};

  @override
  void initState() {
    super.initState();

    tabController =
        TabController(length: 2, vsync: this);

    _initLocale();
  }

  @override
  void dispose() {

    tabController.dispose();

    super.dispose();
  }

  Future<void> _initLocale() async {

    await initializeDateFormatting(
      'id_ID',
      null,
    );

    await fetchRiwayat();
  }

  // ================= FETCH RIWAYAT =================
  Future<void> fetchRiwayat() async {

    try {

      // ================= RIWAYAT NORMAL =================
      final responseNormal =
          await supabase
              .from('hafalan_santri')
              .select('''
                id,
                kitab,
                bagian,
                bagian_awal,
                bagian_akhir,
                status,
                tanggal,
                pembimbing_input,
                santri: santri_id (
                  nama_lengkap
                )
              ''')
              .eq(
                'pembimbing_input',
                widget.username,
              )
              .eq(
                'is_setoran_cadangan',
                false,
              )
              .order(
                'tanggal',
                ascending: false,
              );

      // ================= RIWAYAT CADANGAN =================
      final responseCadangan =
          await supabase
              .from('hafalan_santri')
              .select('''
                id,
                kitab,
                bagian,
                status,
                tanggal,
                pembimbing_input,
                pembimbing_pengganti,
                santri: santri_id (
                  nama_lengkap
                )
              ''')
              .eq(
                'pembimbing_pengganti',
                widget.username,
              )
              .eq(
                'is_setoran_cadangan',
                true,
              )
              .order(
                'tanggal',
                ascending: false,
              );

      // ================= GROUP NORMAL =================
      final Map<String,
          List<Map<String, dynamic>>>
          tempNormal = {};

      for (final item
          in responseNormal) {

        final tanggal =
            DateTime.parse(
                item['tanggal']);

        final key = DateFormat(
          'EEEE, dd MMMM yyyy',
          'id_ID',
        ).format(tanggal);

        tempNormal.putIfAbsent(
            key, () => []);

        tempNormal[key]!.add(item);
      }

      // ================= GROUP CADANGAN =================
      final Map<String,
          List<Map<String, dynamic>>>
          tempCadangan = {};

      for (final item
          in responseCadangan) {

        final tanggal =
            DateTime.parse(
                item['tanggal']);

        final key = DateFormat(
          'EEEE, dd MMMM yyyy',
          'id_ID',
        ).format(tanggal);

        tempCadangan.putIfAbsent(
            key, () => []);

        tempCadangan[key]!.add(item);
      }

      setState(() {

        groupedNormal =
            tempNormal;

        groupedCadangan =
            tempCadangan;

        isLoading = false;
      });

    } catch (e) {

      debugPrint(
        'Error riwayat hafalan: $e',
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor:
            Colors.lime[400],

        automaticallyImplyLeading:
            false,

        title: const Text(
          'Riwayat Hafalan',
          style: TextStyle(
            color: Colors.black,
          ),
        ),

        bottom: TabBar(

          controller:
              tabController,

          labelColor:
              Colors.black,

          tabs: const [

            Tab(
              text:
                  'Riwayat Normal',
            ),

            Tab(
              text:
                  'Riwayat Cadangan',
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : TabBarView(

              controller:
                  tabController,

              children: [

                // ================= NORMAL =================
                buildRiwayat(
                  groupedNormal,
                  false,
                ),

                // ================= CADANGAN =================
                buildRiwayat(
                  groupedCadangan,
                  true,
                ),
              ],
            ),
    );
  }

  // ================= BUILD RIWAYAT =================
  Widget buildRiwayat(
    Map<String,
            List<
                Map<String, dynamic>>>
        groupedData,

    bool isCadangan,
  ) {

    if (groupedData.isEmpty) {

      return Center(
        child: Text(

          isCadangan
              ? 'Belum ada riwayat setoran cadangan'
              : 'Belum ada riwayat setoran',

        ),
      );
    }

    return ListView(

      padding:
          const EdgeInsets.all(12),

      children:
          groupedData.entries.map(
        (entry) {

          return Column(

            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [

              const SizedBox(
                  height: 16),

              Center(

                child: Container(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey[300],

                    borderRadius:
                        BorderRadius.circular(
                            6),
                  ),

                  child: Text(

                    entry.key,

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                  height: 10),

              _buildTable(
                entry.value,
                isCadangan,
              ),
            ],
          );
        },
      ).toList(),
    );
  }

  // ================= TABLE =================
  Widget _buildTable(
    List<Map<String, dynamic>> data,
    bool isCadangan,
  ) {

    return Table(

      border: TableBorder.all(
        color: Colors.black,
      ),

      columnWidths: isCadangan
          ? const {

              0: FixedColumnWidth(40),

              1: FlexColumnWidth(2),

              2: FlexColumnWidth(2),

              3: FlexColumnWidth(3),

              4: FlexColumnWidth(2),

              5: FlexColumnWidth(2),
            }
          : const {

              0: FixedColumnWidth(40),

              1: FlexColumnWidth(2),

              2: FlexColumnWidth(2),

              3: FlexColumnWidth(3),

              4: FlexColumnWidth(2),
            },

      children: [

        _tableHeader(isCadangan),

        ...List.generate(
          data.length,
          (index) {

            final item =
                data[index];

            final nama =
                item['santri']
                        ?[
                        'nama_lengkap'] ??
                    '-';

            final kitab =
                item['kitab'] ??
                    '-';

            final hafalan =
                item['bagian'] ??
                    '-';

            final status =
                item['status'] ??
                    '-';

            if (isCadangan) {

              final pembimbing =
                  item[
                          'pembimbing_input'] ??
                      '-';

              return TableRow(
                children: [

                  _cell(
                    '${index + 1}',
                    isCenter: true,
                  ),

                  _cell(nama),

                  _cell(kitab),

                  _cell(hafalan),

                  _cell(status),

                  _cell(
                      pembimbing),
                ],
              );
            }

            return TableRow(
              children: [

                _cell(
                  '${index + 1}',
                  isCenter: true,
                ),

                _cell(nama),

                _cell(kitab),

                _cell(hafalan),

                _cell(status),
              ],
            );
          },
        ),
      ],
    );
  }

  // ================= HEADER =================
  TableRow _tableHeader(
      bool isCadangan) {

    return TableRow(

      decoration:
          BoxDecoration(
        color: Colors.grey[300],
      ),

      children: isCadangan
          ? const [

              Padding(
                padding:
                    EdgeInsets.all(6),

                child: Center(
                  child: Text(
                    'No',

                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.all(6),

                child: Text(
                  'Nama',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.all(6),

                child: Text(
                  'Kitab',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.all(6),

                child: Text(
                  'Hafalan',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.all(6),

                child: Text(
                  'Status',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.all(6),

                child: Text(
                  'Pembimbing Pengganti',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ]
          : const [

              Padding(
                padding:
                    EdgeInsets.all(6),

                child: Center(
                  child: Text(
                    'No',

                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.all(6),

                child: Text(
                  'Nama',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.all(6),

                child: Text(
                  'Kitab',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.all(6),

                child: Text(
                  'Hafalan',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.all(6),

                child: Text(
                  'Status',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
    );
  }

  // ================= CELL =================
  Widget _cell(
    String text, {
    bool isCenter = false,
  }) {

    return Padding(

      padding:
          const EdgeInsets.all(6),

      child: isCenter
          ? Center(
              child: Text(text),
            )
          : Text(text),
    );
  }
}