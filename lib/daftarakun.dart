import 'package:flutter/material.dart';
import 'package:hafalan_kitab/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'koneksi/supabase_config.dart';

class DaftarAkun extends StatefulWidget {
  const DaftarAkun({super.key});

  @override
  State<DaftarAkun> createState() => _DaftarAkunState();
}

class _DaftarAkunState extends State<DaftarAkun> {

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _namaLengkapController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  String? _selectedMarhalah;

  bool _isLoading = false;

  Future<void> _daftarAkun() async {

    final username =
        _usernameController.text.trim();

    final namaLengkap =
        _namaLengkapController.text.trim();

    final password =
        _passwordController.text.trim();

    final marhalah =
        _selectedMarhalah;

    if (username.isEmpty ||
        namaLengkap.isEmpty ||
        password.isEmpty ||
        marhalah == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Semua kolom wajib diisi',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      // ================= CEK USERNAME =================
      final checkUser =
          await SupabaseConfig.client
              .from('pembimbing')
              .select()
              .eq('username', username)
              .maybeSingle();

      if (checkUser != null) {
        throw 'Username sudah digunakan';
      }

      // ================= INSERT DATA =================
      await SupabaseConfig.client
          .from('pembimbing')
          .insert({

        'username': username,
        'nama_lengkap': namaLengkap,
        'password': password,
        'marhalah': marhalah,

      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registrasi berhasil',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const Login(),
        ),
      );

    } catch (error) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal daftar: $error',
          ),
        ),
      );

    } finally {

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar: AppBar(
        title:
            const Text(
              'Daftar Akun Pembimbing',
            ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(24.0),

        child: Column(
          children: [

            const SizedBox(height: 16),

            // ================= USERNAME =================
            TextField(
              controller:
                  _usernameController,

              decoration:
                  const InputDecoration(
                labelText: 'Username',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ================= NAMA LENGKAP =================
            TextField(
              controller:
                  _namaLengkapController,

              decoration:
                  const InputDecoration(
                labelText: 'Nama Lengkap',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ================= PASSWORD =================
            TextField(
              controller:
                  _passwordController,

              obscureText: true,

              decoration:
                  const InputDecoration(
                labelText: 'Password',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ================= MARHALAH =================
            DropdownButtonFormField<String>(

              value:
                  _selectedMarhalah,

              items: [
                'Marhalah 1',
                'Marhalah 2',
                'Marhalah 3',
              ]
                  .map(
                    (label) =>
                        DropdownMenuItem(
                      value: label,
                      child: Text(label),
                    ),
                  )
                  .toList(),

              onChanged: (value) {

                setState(() {
                  _selectedMarhalah =
                      value;
                });
              },

              decoration:
                  const InputDecoration(
                labelText:
                    'Pilih Marhalah',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(

              width:
                  double.infinity,

              child: ElevatedButton(

                onPressed:
                    _isLoading
                        ? null
                        : _daftarAkun,

                child:
                    _isLoading
                        ? const CircularProgressIndicator(
                            color:
                                Colors.white,
                          )
                        : const Text(
                            'Daftar',
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}