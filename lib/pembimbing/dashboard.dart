
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profil.dart';
import 'keloladatasantri/keloladatasantri.dart';
import 'marhalah1/pilih_kitab.dart';
import 'riwayathafalan.dart';

class DashboardPage extends StatefulWidget {

  final String idPembimbing;
  final String username;
  final String marhalah;

  const DashboardPage({
    super.key,
    required this.idPembimbing,
    required this.username,
    required this.marhalah,
  });

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState
    extends State<DashboardPage> {

  final supabase =
      Supabase.instance.client;

  int _selectedIndex = 0;

  bool loadingKhataman = true;

  List<Map<String, dynamic>>
      dataKhataman = [];

  // ================= DATA PROFIL =================
  String namaPembimbing = '';
  String? fotoProfil;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    fetchSetoranKhataman();

    loadProfilPembimbing();

    _pages = [
      buildBeranda(),

      const PilihKitabPage(),

      const RiwayatHafalanPage(),

      KelolaDataSantri(
        marhalah: widget.marhalah,
      ),
    ];
  }

  // ================= LOAD PROFIL =================
  Future<void>
      loadProfilPembimbing() async {
    try {

      final data = await supabase
          .from('pembimbing')
          .select()
          .eq(
            'id',
            widget.idPembimbing,
          )
          .maybeSingle();

      if (data == null) return;

      setState(() {

        namaPembimbing =
            data['username'] ?? '';

        fotoProfil =
            data['foto_profil'];

      });

    } catch (e) {

      print(
        'Gagal load profil: $e',
      );
    }
  }

  // ================= FETCH SETORAN =================
  Future<void>
      fetchSetoranKhataman() async {

    setState(() {
      loadingKhataman = true;
    });

    try {

      final data = await supabase
          .from('setoran_khataman')
          .select('''
            id,
            kitab,
            status,
            tanggal_pengajuan,
            tanggal_setoran,
            santri (
              nama_lengkap,
              kelas
            )
          ''')
          .order(
            'tanggal_pengajuan',
            ascending: false,
          );

      if (!mounted) return;

      setState(() {

        dataKhataman =
            List<Map<String,
                dynamic>>.from(data);

        loadingKhataman = false;

      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        loadingKhataman = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Gagal mengambil data khataman: $e",
          ),
        ),
      );
    }
  }

  // ================= REFRESH =================
  void refreshPages() {

    setState(() {

      _pages = [

        buildBeranda(),

        const PilihKitabPage(),

        const RiwayatHafalanPage(),

        KelolaDataSantri(
          marhalah: widget.marhalah,
        ),
      ];
    });
  }

  // ================= NAVIGATION =================
  void _onItemTapped(
      int index) async {

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {

      await fetchSetoranKhataman();

      refreshPages();
    }
  }

  // ================= LOGOUT =================
  void _logout() {

    Navigator.pushReplacementNamed(
      context,
      '/login',
    );
  }

  // ================= TITLE =================
  String _getTitle() {

    switch (_selectedIndex) {

      case 0:
        return 'Beranda';

      case 1:
        return 'Catat Hafalan';

      case 2:
        return 'Riwayat Hafalan';

      case 3:
        return 'Kelola Data Santri';

      default:
        return '';
    }
  }

  // ================= BERANDA =================
  Widget buildBeranda() {

    return RefreshIndicator(

      onRefresh:
          fetchSetoranKhataman,

      child: ListView(
        padding:
            const EdgeInsets.all(
                16),

        children: [

          // ================= HEADER =================
          Container(
            padding:
                const EdgeInsets.all(
                    20),

            decoration:
                BoxDecoration(
              color:
                  Colors.lime[400],

              borderRadius:
                  BorderRadius.circular(
                      24),
            ),

            child: Row(
              children: [

                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Colors.white,

                  backgroundImage:
                      fotoProfil != null
                          ? NetworkImage(
                              fotoProfil!,
                            )
                          : null,

                  child:
                      fotoProfil == null
                          ? const Icon(
                              Icons
                                  .menu_book_rounded,
                              size: 30,
                              color:
                                  Colors.black,
                            )
                          : null,
                ),

                const SizedBox(
                    width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      const Text(
                        "Dashboard Pembimbing",
                        style:
                            TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                          height: 4),

                      Text(
                        widget.marhalah,
                        style:
                            const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 24),

          // ================= INFO =================
          Row(
            children: [

              Expanded(
                child: buildInfoCard(
                  title:
                      "Total Pengajuan",
                  value:
                      "${dataKhataman.length}",
                  icon:
                      Icons.assignment,
                ),
              ),

              const SizedBox(
                  width: 12),

              Expanded(
                child: buildInfoCard(
                  title: "Pending",

                  value:
                      "${dataKhataman.where((e) => e['status'] == 'pending').length}",

                  icon:
                      Icons.access_time,
                ),
              ),
            ],
          ),

          const SizedBox(
              height: 24),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              const Text(
                "Setoran Khataman",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              IconButton(
                onPressed:
                    showSantriKhatamDialog,

                icon: const Icon(
                  Icons
                      .add_circle_outline,
                ),
              ),
            ],
          ),

          const SizedBox(
              height: 10),

          // ================= LOADING =================
          if (loadingKhataman)
            const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(
                        30),

                child:
                    CircularProgressIndicator(),
              ),
            )

          // ================= EMPTY =================
          else if (dataKhataman
              .isEmpty)

            Container(
              padding:
                  const EdgeInsets.all(
                      24),

              decoration:
                  BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                        20),
              ),

              child:
                  const Column(
                children: [

                  Icon(
                    Icons.info_outline,
                    size: 50,
                    color:
                        Colors.grey,
                  ),

                  SizedBox(
                      height: 12),

                  Text(
                    "Belum ada data setoran khataman",
                    style: TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),
            )

          // ================= LIST =================
          else

            ...List.generate(
              dataKhataman.length,
              (i) {

                final item =
                    dataKhataman[i];

                final santri =
                    item['santri'];

                return Container(

                  margin:
                      const EdgeInsets
                          .only(
                    bottom: 14,
                  ),

                  padding:
                      const EdgeInsets
                          .all(18),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,

                    borderRadius:
                        BorderRadius
                            .circular(
                                22),
                  ),

                  child: Row(
                    children: [

                      CircleAvatar(
                        backgroundColor:
                            Colors
                                .lime[400],

                        child:
                            const Icon(
                          Icons.person,
                          color: Colors
                              .black,
                        ),
                      ),

                      const SizedBox(
                          width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              santri[
                                  'nama_lengkap'],

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,

                                fontSize:
                                    16,
                              ),
                            ),

                            const SizedBox(
                                height:
                                    4),

                            Text(
                              "Kitab ${item['kitab']}",
                            ),

                            Text(
                              "Kelas ${santri['kelas']}",
                            ),
                          ],
                        ),
                      ),

                      buildStatusBadge(
                        item['status'],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ================= INFO CARD =================
  Widget buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {

    return Container(

      padding:
          const EdgeInsets.all(
              18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                20),
      ),

      child: Column(
        children: [

          Icon(icon, size: 30),

          const SizedBox(
              height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
              height: 4),

          Text(title),
        ],
      ),
    );
  }

  // ================= STATUS =================
  Widget buildStatusBadge(
      String status) {

    Color warna =
        Colors.orange;

    if (status ==
        'disetujui') {
      warna = Colors.green;
    }

    if (status ==
        'ditolak') {
      warna = Colors.red;
    }

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),

      decoration:
          BoxDecoration(
        color:
            warna.withOpacity(0.2),

        borderRadius:
            BorderRadius.circular(
                20),
      ),

      child: Text(
        status.toUpperCase(),

        style: TextStyle(
          color: warna,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ================= DIALOG =================
  void showSantriKhatamDialog()
      async {}

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[300],

      appBar: AppBar(
        backgroundColor:
            Colors.grey[300],

        elevation: 0,

        title: Text(
          _getTitle(),
          style:
              const TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      // ================= SIDEBAR =================
      drawer: Drawer(

        shape:
            const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(
            topRight:
                Radius.circular(20),
            bottomRight:
                Radius.circular(20),
          ),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .stretch,

          children: [

            UserAccountsDrawerHeader(

              decoration:
                  BoxDecoration(
                color:
                    Colors.lime[400],
              ),

              accountName: Text(
                namaPembimbing
                        .isEmpty
                    ? widget.username
                    : namaPembimbing,
              ),

              accountEmail: Text(
                'Marhalah: ${widget.marhalah}',
              ),

              currentAccountPicture:
                  CircleAvatar(

                backgroundColor:
                    Colors.white,

                backgroundImage:
                    fotoProfil !=
                            null
                        ? NetworkImage(
                            fotoProfil!,
                          )
                        : null,

                child:
                    fotoProfil ==
                            null
                        ? const Icon(
                            Icons
                                .person,
                            size: 40,
                            color: Colors
                                .black,
                          )
                        : null,
              ),
            ),

            // ================= PROFIL =================
            ListTile(

              leading:
                  const Icon(
                Icons.person,
              ),

              title:
                  const Text(
                'Profil',
              ),

              onTap: () async {

                Navigator.pop(
                    context);

                await Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        ProfilPage(

                      idPembimbing:
                          widget
                              .idPembimbing,

                      username:
                          widget
                              .username,

                      marhalah:
                          widget
                              .marhalah,
                    ),
                  ),
                );

                loadProfilPembimbing();
              },
            ),

            // ================= PENGATURAN =================
            ListTile(

              leading:
                  const Icon(
                Icons.settings,
              ),

              title:
                  const Text(
                'Pengaturan',
              ),

              onTap: () {
                Navigator.pop(
                    context);

                Navigator
                    .pushNamed(
                  context,
                  '/pengaturan',
                );
              },
            ),

            const Divider(),

            // ================= LOGOUT =================
            ListTile(

              leading:
                  const Icon(
                Icons.logout,
                color: Colors.red,
              ),

              title:
                  const Text(
                'Logout',
                style: TextStyle(
                  color:
                      Colors.red,
                ),
              ),

              onTap: _logout,
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: _pages[
          _selectedIndex],

      // ================= FLOAT =================
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                  backgroundColor:
                      Colors.lime[400],

                  onPressed:
                      showSantriKhatamDialog,

                  child:
                      const Icon(
                    Icons.add,
                    color:
                        Colors.black,
                  ),
                )
              : null,

      // ================= BOTTOM NAV =================
      bottomNavigationBar:
          Container(

        decoration:
            BoxDecoration(
          color:
              Colors.lime[400],

          borderRadius:
              const BorderRadius
                  .only(
            topLeft:
                Radius.circular(
                    20),
            topRight:
                Radius.circular(
                    20),
          ),
        ),

        child:
            BottomNavigationBar(
          backgroundColor:
              Colors.transparent,

          elevation: 0,

          currentIndex:
              _selectedIndex,

          onTap:
              _onItemTapped,

          selectedItemColor:
              Colors.black,

          unselectedItemColor:
              Colors.black54,

          type:
              BottomNavigationBarType
                  .fixed,

          items: const [

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.home),
              label:
                  'Beranda',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                  Icons.book_online),
              label:
                  'Catat',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                  Icons.history),
              label:
                  'Riwayat',
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.book),
              label:
                  'Santri',
            ),
          ],
        ),
      ),
    );
  }
}
