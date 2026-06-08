import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:hafalan_kitab/koneksi/supabase_config.dart';
import 'package:hafalan_kitab/login.dart';
import 'package:hafalan_kitab/daftarakun.dart';
import 'package:hafalan_kitab/pembimbing/dashboard.dart';
import 'package:hafalan_kitab/pembimbing/keloladatasantri/keloladatasantri.dart';
import 'package:hafalan_kitab/pembimbing/profil.dart';
import 'package:hafalan_kitab/admin/dashboardadmin.dart';
import 'package:hafalan_kitab/admin/approvesetoran.dart';
import 'package:hafalan_kitab/admin/monitoring.dart';
import 'package:hafalan_kitab/walisantri/dashboardwali.dart'; // 🛠️ FIX ERROR 1 & 3: Jalur import disesuaikan ke folder walisantri

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal lokal Indonesia
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Supabase menggunakan konfigurasi bawaan proyekmu
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil session login yang tersimpan di memori HP dari Supabase Auth
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hafalku',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      // 2. Jika session kosong (null), arahkan ke form Login biasa.
      //    Jika session ada, arahkan ke widget pengecekan role 3 aktor.
      home: session == null 
          ? Login() 
          : const PenentuHalamanDashboard(),
    );
  }
}

// ================= WIDGET PERANTARA AUTO LOGIN & PENENTU ROLE =================
class PenentuHalamanDashboard extends StatefulWidget {
  const PenentuHalamanDashboard({super.key});

  @override
  State<PenentuHalamanDashboard> createState() => _PenentuHalamanDashboardState();
}

class _PenentuHalamanDashboardState extends State<PenentuHalamanDashboard> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    periksaSesiDanArahkan();
  }

  Future<void> periksaSesiDanArahkan() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        kembaliKeLogin();
        return;
      }

      final userEmail = user.email ?? '';

      // --------------------------------------------------------
      // ACTOR 1: CEK APAKAH USER ADALAH ADMIN DI DATABASE
      // --------------------------------------------------------
      final dataAdmin = await supabase
          .from('admin') 
          .select()
          .eq('email', userEmail)
          .maybeSingle();

      if (dataAdmin != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardAdminPage()),
        );
        return;
      }

      // --------------------------------------------------------
      // ACTOR 2: CEK APAKAH USER TERDAFTAR DI TABEL PEMBIMBING
      // --------------------------------------------------------
      final dataPembimbing = await supabase
          .from('pembimbing') 
          .select()
          .eq('email', userEmail)
          .maybeSingle();

      if (dataPembimbing != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(
              idPembimbing: dataPembimbing['id'], // 🛠️ FIX ERROR 2: Parameter idPembimbing ditambahkan agar tidak kosong
              username: dataPembimbing['username'] ?? 'Pembimbing',
              marhalah: dataPembimbing['marhalah']?.toString() ?? 'Marhalah 1',
            ),
          ),
        );
        return;
      }

      // --------------------------------------------------------
      // ACTOR 3: CEK APAKAH USER TERDAFTAR DI TABEL WALI SANTRI
      // --------------------------------------------------------
      final dataWali = await supabase
          .from('wali_santri') 
          .select()
          .eq('email', userEmail)
          .maybeSingle();

      if (dataWali != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardWaliPage(
              waliId: dataWali['id'].toString(),
              namaWali: dataWali['nama_wali'] ?? 'Wali Santri',
            ),
          ),
        );
        return;
      }

      // Jika email session aktif ternyata tidak terdaftar di ketiga tabel di atas
      kembaliKeLogin();
    } catch (e) {
      // Jika terjadi error query atau jaringan, amankan dengan melempar ke Login
      kembaliKeLogin();
    }
  }

  void kembaliKeLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
            SizedBox(height: 16),
            Text(
              'Menghubungkan Sesi...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}