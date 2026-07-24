import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ================= WIDGET =================
import 'widgets/monitoring_setorantile.dart';
import 'widgets/monitoring_detaildialog.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  late TabController tabController;

  bool loading = true;

  // ================= SEARCH & FILTER =================
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedKitab = 'Semua Kitab';

  // ================= DATA =================
  List<Map<String, dynamic>> allData = [];
  List<Map<String, dynamic>> marhalah1 = [];
  List<Map<String, dynamic>> marhalah2 = [];
  List<Map<String, dynamic>> marhalah3 = [];
  List<Map<String, dynamic>> marhalah4 = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    fetchMonitoring();
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // ================= GET UNIQUE KITAB LIST =================
  List<String> get daftarKitab {
    final kitabs = <String>{'Semua Kitab'};
    for (var item in allData) {
      if (item['kitab'] != null &&
          item['kitab'].toString().trim().isNotEmpty) {
        kitabs.add(item['kitab'].toString().trim());
      }
    }
    return kitabs.toList();
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

      allData = List<Map<String, dynamic>>.from(response);

      marhalah1 = allData.where((item) {
        final santri = item['santri'];
        return santri != null && santri['marhalah'] == 'Marhalah 1';
      }).toList();

      marhalah2 = allData.where((item) {
        final santri = item['santri'];
        return santri != null && santri['marhalah'] == 'Marhalah 2';
      }).toList();

      marhalah3 = allData.where((item) {
        final santri = item['santri'];
        return santri != null && santri['marhalah'] == 'Marhalah 3';
      }).toList();

      marhalah4 = allData.where((item) {
        final santri = item['santri'];
        return santri != null && santri['marhalah'] == 'Marhalah 4';
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil data monitoring: $e'),
        ),
      );
    }
  }

  // ================= FILTER SEARCH & KITAB =================
  List<Map<String, dynamic>> filterData(List<Map<String, dynamic>> data) {
    return data.where((item) {
      final santri = item['santri'];
      final nama = santri != null
          ? santri['nama_lengkap'].toString().toLowerCase()
          : '';
      final kitab = item['kitab'].toString().toLowerCase();

      final matchesSearch = searchQuery.isEmpty ||
          nama.contains(searchQuery.toLowerCase()) ||
          kitab.contains(searchQuery.toLowerCase());

      final matchesKitab = selectedKitab == 'Semua Kitab' ||
          item['kitab'].toString().trim().toLowerCase() ==
              selectedKitab.toLowerCase();

      return matchesSearch && matchesKitab;
    }).toList();
  }

  // ================= FEATURE: DIALOG & BOTTOM SHEET KITAB =================

  // Panel Bottom Sheet menampilkan Santri yang menghafal Kitab tertentu
  void _showSantriByKitabBottomSheet(String kitabNama) {
    final santriKitab = allData.where((element) {
      return element['kitab'].toString().trim().toLowerCase() ==
          kitabNama.toLowerCase();
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Kitab: $kitabNama',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${santriKitab.length} Santri',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.lime[300],
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),
                  Expanded(
                    child: santriKitab.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada santri yang menghafal kitab ini.',
                            ),
                          )
                        : ListView.builder(
                            controller: controller,
                            itemCount: santriKitab.length,
                            itemBuilder: (context, index) {
                              final item = santriKitab[index];
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Dialog daftar pilihan Kitab saat Icon Buku di AppBar diklik
  void _showPilihKitabDialog() {
    final kitabsOnly = daftarKitab.where((k) => k != 'Semua Kitab').toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.menu_book, color: Colors.black87),
            SizedBox(width: 8),
            Text('Daftar Kitab Hafalan'),
          ],
        ),
        content: kitabsOnly.isEmpty
            ? const Text('Belum ada data kitab.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: kitabsOnly.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final kitab = kitabsOnly[index];
                    final count = allData
                        .where((e) =>
                            e['kitab'].toString().trim().toLowerCase() ==
                            kitab.toLowerCase())
                        .length;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.book,
                        color: Colors.lime,
                      ),
                      title: Text(
                        kitab,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count Santri',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showSantriByKitabBottomSheet(kitab);
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // ================= BUILD LIST =================
  Widget buildMonitoringList(List<Map<String, dynamic>> dataMonitoring) {
    final filteredData = filterData(dataMonitoring);

    if (filteredData.isEmpty) {
      return const Center(
        child: Text('Belum ada data hafalan'),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchMonitoring,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          final item = filteredData[index];

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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Monitoring Hafalan'),
        backgroundColor: Colors.lime[400],
        actions: [
          // TOMBOL MENU KITAB UNTUK PIMPINAN
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Lihat Santri per Kitab',
            onPressed: _showPilihKitabDialog,
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: Colors.black,
          tabs: const [
            Tab(text: 'Marhalah 1'),
            Tab(text: 'Marhalah 2'),
            Tab(text: 'Marhalah 3'),
            Tab(text: 'Marhalah 4'),
          ],
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // ================= SEARCH & DROPDOWN FILTER KITAB =================
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Input Search
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari nama santri atau kitab...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {
                                      searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      // Dropdown Filter Kitab
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.filter_alt_outlined,
                              size: 20,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Kitab:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedKitab,
                                  isExpanded: true,
                                  items: daftarKitab.map((String kitab) {
                                    return DropdownMenuItem<String>(
                                      value: kitab,
                                      child: Text(
                                        kitab,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedKitab = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= TAB VIEW =================
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      buildMonitoringList(marhalah1),
                      buildMonitoringList(marhalah2),
                      buildMonitoringList(marhalah3),
                      buildMonitoringList(marhalah4),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}