import 'package:flutter/material.dart';
import 'package:hafalan_kitab/koneksi/supabase_config.dart';
import 'package:hafalan_kitab/login.dart';
import 'package:hafalan_kitab/pembimbing/dashboard.dart'; // pastikan path benar
import 'package:hafalan_kitab/pembimbing/keloladatasantri/keloladatasantri.dart';
import 'package:hafalan_kitab/pembimbing/profil.dart';
import 'package:intl/date_symbol_data_local.dart';

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
      title: 'Hafalan Kitab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
                                                  // Ganti halaman awal di sini
      home: DashboardPage
    //KelolaDataSantri(),
  (
    username: 'Guest',
    marhalah: 'Marhalah 1',),
  );
  }
}
