import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hafalan_kitab/pembimbing/dashboard.dart';
import 'package:hafalan_kitab/admin/dashboardadmin.dart';
import 'package:hafalan_kitab/walisantri/dashboardwali.dart'; // 🛠️ FIX ERROR 1 & 2: Jalur import dipindahkan ke folder walisantri
import 'daftarakun.dart';
import 'bantuanlogin.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final supabase = Supabase.instance.client;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isObscure = true;
  bool isLoading = false;

  // ================= FUNCTION LOGIN =================
  Future<void> _login() async {
    String username = usernameController.text.trim().toLowerCase();
    String password = passwordController.text.trim();

    // ================= VALIDASI INPUT =================
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan password wajib diisi"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      debugPrint('USERNAME INPUT : $username');
      debugPrint('PASSWORD INPUT : $password');

      // ================= QUERY LOGIN AKTOR: PEMBIMBING / ADMIN =================
      final response = await supabase
          .from('pembimbing')
          .select(
            '''
            id,
            username,
            nama_lengkap,
            marhalah,
            password,
            role
            ''',
          )
          .eq('username', username)
          .maybeSingle();

      debugPrint('HASIL QUERY PEMBIMBING/ADMIN : $response');

      // ================= JIKA USER DITEMUKAN DI TABEL PEMBIMBING =================
      if (response != null) {
        // Verifikasi Password
        if (response['password'] == password) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login berhasil")),
          );

          final role = response['role'] ?? 'pembimbing';

          // Arahkan Sesuai Role
          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardAdminPage(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(
                  idPembimbing: response['id'],
                  username: response['username'],
                  marhalah: response['marhalah'],
                ),
              ),
            );
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password salah")),
          );
        }
      } 
      // ================= JIKA TIDAK DITEMUKAN, CEK TABEL WALI SANTRI =================
      else {
        final wali = await supabase
            .from('wali_santri')
            .select()
            .eq('username', username)
            .eq('password', password)
            .maybeSingle();

        debugPrint('HASIL QUERY WALI SANTRI : $wali');

        if (wali != null) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardWaliPage(
                waliId: wali['id'].toString(),
                namaWali: wali['nama_wali'] ?? 'Wali Santri',
              ),
            ),
          );
          return;
        }

        // Jika data benar-benar tidak ada di kedua tabel
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username tidak ditemukan")),
        );
      }
    } catch (e) {
      debugPrint('ERROR LOGIN : $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal login: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ================= LOGO BARU (OPTIMAL & UTUH) =================
              Image.asset(
                'assets/logobaru.png',
                width: 280, 
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),

              // ================= JUDUL INTERFACE =================
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // ================= TEXTFIELD: USERNAME =================
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // ================= TEXTFIELD: PASSWORD =================
              TextField(
                controller: passwordController,
                obscureText: isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ================= TOMBOL MASUK =================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.deepPurple,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('Masuk'),
                ),
              ),

              // ================= LINK: BANTUAN AKUN =================
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BantuanLoginPage(),
                    ),
                  );
                },
                child: const Text(
                  'Lupa Username/Password?',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ================= LINK: REGISTRASI AKUN =================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DaftarAkun(),
                        ),
                      );
                    },
                    child: const Text("Daftar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}