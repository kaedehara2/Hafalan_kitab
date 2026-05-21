import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ================= WIDGET =================
import 'widgets/monitoring_setorantile.dart';
import 'widgets/monitoring_detaildialog.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() =>
      _MonitoringPageState();
}

class _MonitoringPageState
    extends State<MonitoringPage>
    with SingleTickerProviderStateMixin {

  final supabase =
      Supabase.instance.client;

  late TabController tabController;

  bool loading = true;

  // ================= SEARCH =================
  final TextEditingController
      searchController =
          TextEditingController();

  String searchQuery = '';

  // ================= DATA =================
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

    fetchMonitoring();
  }

  @override
  void dispose() {

    tabController.dispose();

    searchController.dispose();

    super.dispose();
  }

  // ================= FETCH DATA =================
  Future<void> fetchMonitoring() async {

    setState(() {
      loading = true;
    });

    try {

      final response = await supabase
          .from('hafalan_santri')
          .select('''
            id,
            kitab,
            bagian,
            status,
            tanggal,
            is_setoran_cadangan,
            pembimbing_input,
            pembimbing_pengganti,
            santri (
              nama_lengkap,
              kelas,
              marhalah
            )
          ''')
          .order(
            'tanggal',
            ascending: false,
          );

      final data =
          List<Map<String,
              dynamic>>.from(response);

      marhalah1 =
          data.where((item) {

        final santri =
            item['santri'];

        return santri != null &&
            santri['marhalah'] ==
                'Marhalah 1';

      }).toList();

      marhalah2 =
          data.where((item) {

        final santri =
            item['santri'];

        return santri != null &&
            santri['marhalah'] ==
                'Marhalah 2';

      }).toList();

      marhalah3 =
          data.where((item) {

        final santri =
            item['santri'];

        return santri != null &&
            santri['marhalah'] ==
                'Marhalah 3';

      }).toList();

      marhalah4 =
          data.where((item) {

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
            'Gagal mengambil data monitoring: $e',
          ),
        ),
      );
    }
  }

  // ================= FILTER SEARCH =================
  List<Map<String, dynamic>>
      filterData(
    List<Map<String, dynamic>>
        data,
  ) {

    if (searchQuery.isEmpty) {
      return data;
    }

    return data.where((item) {

      final santri =
          item['santri'];

      final nama =
          santri['nama_lengkap']
              .toString()
              .toLowerCase();

      final kitab =
          item['kitab']
              .toString()
              .toLowerCase();

      return nama.contains(
                searchQuery
                    .toLowerCase(),
              ) ||
          kitab.contains(
            searchQuery
                .toLowerCase(),
          );

    }).toList();
  }

  // ================= BUILD LIST =================
  Widget buildMonitoringList(
    List<Map<String, dynamic>>
        dataMonitoring,
  ) {

    final filteredData =
        filterData(
      dataMonitoring,
    );

    if (filteredData.isEmpty) {

      return const Center(
        child: Text(
          'Belum ada data hafalan',
        ),
      );
    }

    return RefreshIndicator(

      onRefresh:
          fetchMonitoring,

      child: ListView.builder(

        padding:
            const EdgeInsets.all(
                16),

        itemCount:
            filteredData.length,

        itemBuilder:
            (context, index) {

          final item =
              filteredData[index];

          return MonitoringSetoranTile(

            item: item,

            onTap: () {

              showMonitoringDetailDialog(

                context: context,

                item: item,
              );
            },
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
          'Monitoring Hafalan',
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

          : Column(

              children: [

                // ================= SEARCH =================
                Padding(

                  padding:
                      const EdgeInsets.all(
                          16),

                  child: TextField(

                    controller:
                        searchController,

                    decoration:
                        InputDecoration(

                      hintText:
                          'Cari nama santri atau kitab...',

                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),

                      filled: true,

                      fillColor:
                          Colors.white,

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius.circular(
                                16),

                        borderSide:
                            BorderSide.none,
                      ),
                    ),

                    onChanged: (value) {

                      setState(() {

                        searchQuery =
                            value;
                      });
                    },
                  ),
                ),

                // ================= TAB VIEW =================
                Expanded(

                  child:
                      TabBarView(

                    controller:
                        tabController,

                    children: [

                      buildMonitoringList(
                        marhalah1,
                      ),

                      buildMonitoringList(
                        marhalah2,
                      ),

                      buildMonitoringList(
                        marhalah3,
                      ),

                      buildMonitoringList(
                        marhalah4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}