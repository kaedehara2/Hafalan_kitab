import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hafalan_kitab/login.dart';

import 'profil.dart';
import 'keloladatasantri/keloladatasantri.dart';
import 'package:hafalan_kitab/pembimbing/pilihkitab.dart';
import 'riwayathafalan.dart';
import 'setorancadangan.dart';
import 'datakhataman.dart';
import 'pencapaianhafalan/pencapaianhafalan1.dart';
import 'pencapaianhafalan/pencapaianhafalan2.dart';
import 'pencapaianhafalan/pencapaianhafalan3.dart';
import 'pencapaianhafalan/pencapaianhafalan4.dart';
import 'chat_wali/chat_list_pembimbing_page.dart';

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
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 0;

  // ================= DATA PROFIL =================
  String namaPembimbing = '';
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    loadProfilPembimbing();
    buildPages();
  }

  // ================= BUILD PAGES =================
  void buildPages() {
    _pages = [
      buildBeranda(),
      PilihKitabPage(
        username: widget.username,
        marhalah: widget.marhalah,
      ),
      RiwayatHafalanPage(
        username: widget.username,
      ),
      KelolaDataSantri(
        marhalah: widget.marhalah,
      ),
    ];
  }

  // ================= LOAD PROFIL =================
  Future<void> loadProfilPembimbing() async {
    try {
      final data = await supabase
          .from('pembimbing')
          .select()
          .eq('id', widget.idPembimbing)
          .maybeSingle();

      if (data == null) return;

      setState(() {
        namaPembimbing = data['username'] ?? '';
      });
    } catch (e) {
      debugPrint('Gagal load profil: $e');
    }
  }

  // ================= REFRESH =================
  void refreshPages() {
    setState(() {
      buildPages();
    });
  }

  // ================= NAVIGATION =================
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      refreshPages();
    }
  }

  // ================= LOGOUT (Telah Diperbaiki) =================
  Future<void> _logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda ingin logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    // ================= SINKRONISASI LOGOUT DATABASE & ROUTING =================
    if (konfirmasi == true) {
      try {
        // Tampilkan loading screen singkat saat proses logout di Supabase
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(color: Colors.deepPurple),
          ),
        );

        // 🛠️ FIX LOGOUT: Hancurkan session auth token Supabase di lokal HP
        await supabase.auth.signOut();

        if (!mounted) return;
        Navigator.pop(context); // Tutup loading dialog

        // Bersihkan stack page dan lempar kembali ke halaman Login awal
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Tutup loading jika gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal logout secara bersih: $e")),
        );
      }
    }
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ================= HEADER =================
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.lime[400],
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dashboard Pembimbing",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.marhalah,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ================= MENU KHATAMAN =================
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                  ),
                ),
                title: const Text("Data Setoran Khataman"),
                subtitle: const Text("Lihat data santri yang siap setoran"),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DataKhatamanPage(
                        marhalah: widget.marhalah,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ================= INFO =================
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informasi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: buildInfoCard(
                      title: "Marhalah",
                      value: widget.marhalah,
                      icon: Icons.school,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildInfoCard(
                      title: "Pembimbing",
                      value: namaPembimbing.isEmpty
                          ? widget.username
                          : namaPembimbing,
                      icon: Icons.person,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= INFO CARD =================
  Widget buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }

  // ================= UI MAIN METODE =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: Text(
          _getTitle(),
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      // ================= SIDEBAR DRAWER =================
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lime[400],
              ),
              accountName: Text(
                namaPembimbing.isEmpty ? widget.username : namaPembimbing,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                'Marhalah: ${widget.marhalah}',
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.black,
                ),
              ),
            ),

            // ================= MENU ITEMS =================
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilPage(
                      idPembimbing: widget.idPembimbing,
                      username: widget.username,
                      marhalah: widget.marhalah,
                    ),
                  ),
                );
                await loadProfilPembimbing();
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.blue),
              title: const Text('Chat Wali Santri'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatListPembimbingPage(
                      idPembimbing: widget.idPembimbing,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.orange),
              title: const Text('Setoran Cadangan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SetoranCadanganPage(
                      username: widget.username,
                      marhalah: widget.marhalah,
                    ),
                  ),
                );
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.check_box, color: Colors.green),
              title: const Text('Pencapaian Hafalan'),
              onTap: () {
                Navigator.pop(context);
                if (widget.marhalah == 'Marhalah 1') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PencapaianHafalan1Page(marhalah: widget.marhalah),
                    ),
                  );
                } else if (widget.marhalah == 'Marhalah 2') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PencapaianHafalan2Page(marhalah: widget.marhalah),
                    ),
                  );
                } else if (widget.marhalah == 'Marhalah 3') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PencapaianHafalan3Page(marhalah: widget.marhalah),
                    ),
                  );
                } else if (widget.marhalah == 'Marhalah 4') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PencapaianHafalan4Page(marhalah: widget.marhalah),
                    ),
                  );
                }
              },
            ),
            const Spacer(),
            const Divider(),

            // ================= BUTTON LOGOUT =================
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.lime[400],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Catat'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Santri'),
          ],
        ),
      ),
    );
  }
}