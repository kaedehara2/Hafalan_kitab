import 'package:flutter/material.dart';
import 'profil.dart';
import 'keloladatasantri/keloladatasantri.dart';
import 'marhalah1/pilih_kitab.dart';
import 'riwayathafalan.dart'; // 🔥 HUBUNGKAN KE FILE RIWAYAT ASLI

class DashboardPage extends StatefulWidget {
  final String username;
  final String marhalah;

  const DashboardPage({
    super.key,
    required this.username,
    required this.marhalah,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      // index 0 → Beranda / Jadwal
      Center(
        child: Image.asset(
          'assets/logo.png',
          height: 80,
        ),
      ),

      // index 1 → Catat Hafalan (Pilih Kitab)
      const PilihKitabPage(),

      // index 2 → Riwayat Hafalan (SUDAH TERHUBUNG KE SUPABASE)
      const RiwayatHafalanPage(),

      // index 3 → Kelola Data Santri
      const KelolaDataSantri(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Beranda M1';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: Text(
          _getTitle(),
          style: const TextStyle(color: Colors.black),
        ),
      ),

      // ================= DRAWER =================
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
              decoration: BoxDecoration(color: Colors.lime[400]),
              accountName: Text(widget.username),
              accountEmail: Text('Marhalah: ${widget.marhalah}'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.black),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilPage(
                      username: widget.username,
                      marhalah: widget.marhalah,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/pengaturan');
              },
            ),
            const Divider(),
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

      // ================= BODY =================
      body: _pages[_selectedIndex],

      // ================= BOTTOM NAV =================
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
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'Catat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Santri',
            ),
          ],
        ),
      ),
    );
  }
}
