import 'package:flutter/material.dart';
import 'package:hafalan_kitab/koneksi/supabase_config.dart';
import 'package:hafalan_kitab/login.dart';
import 'package:hafalan_kitab/pembimbing/dashboard.dart';
import 'package:hafalan_kitab/pembimbing/keloladatasantri/keloladatasantri.dart';
import 'package:hafalan_kitab/pembimbing/marhalah2/jurumiyah.dart';
import 'package:hafalan_kitab/pembimbing/profil.dart';
import 'package:hafalan_kitab/daftarakun.dart'; // tambah ini
import 'package:intl/date_symbol_data_local.dart';
import 'package:hafalan_kitab/admin/dashboardadmin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Hafalku',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),

      // ================= HALAMAN AWAL =================
      //home: const DaftarAkun(),
//home: JurumiyahPage(),
      // contoh lain:
      home: DashboardAdminPage(),
      // home: Login(),
      // home: DashboardPage(username: 'Guest', marhalah: 'Marhalah 1'),
      // home: KelolaDataSantri(),
    );
  }
}