import 'package:flutter/material.dart';
import 'package:hafalan_kitab/pembimbing/dashboard.dart';
import 'package:hafalan_kitab/admin/dashboardadmin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'daftarakun.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isObscure = true;
  bool isLoading = false;

  // ================= LOGIN =================
  Future<void> _login() async {

    String username =
        usernameController.text
            .trim()
            .toLowerCase();

    String password =
        passwordController.text
            .trim();

    // ================= VALIDASI =================
    if (username.isEmpty ||
        password.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Username dan password wajib diisi",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      print('USERNAME INPUT : $username');
      print('PASSWORD INPUT : $password');

      // ================= QUERY LOGIN =================
      final response =
          await Supabase.instance.client
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

      print('HASIL QUERY : $response');

      // ================= CEK USER =================
      if (response != null) {

        // ================= CEK PASSWORD =================
        if (response['password'] == password) {

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "Login berhasil",
              ),
            ),
          );

          // ================= ROLE =================
          final role =
              response['role'] ?? 'pembimbing';

          // ================= LOGIN ADMIN =================
          if (role == 'admin') {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const DashboardAdminPage(),
              ),
            );

          }

          // ================= LOGIN PEMBIMBING =================
          else {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(

                  idPembimbing:
                      response['id'],

                  username:
                      response['username'],

                  marhalah:
                      response['marhalah'],
                ),
              ),
            );
          }

        } else {

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "Password salah",
              ),
            ),
          );
        }

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Username tidak ditemukan",
            ),
          ),
        );
      }

    } catch (e) {

      print('ERROR LOGIN : $e');

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Gagal login: $e",
          ),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F5F5),

      body: Center(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(24.0),

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              // ================= LOGO =================
              Image.asset(
                'assets/logobaru.png',
                height: 100,
              ),

              const SizedBox(height: 20),

              // ================= JUDUL =================
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // ================= USERNAME =================
              TextField(

                controller:
                    usernameController,

                decoration:
                    const InputDecoration(

                  labelText:
                      'Username',

                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // ================= PASSWORD =================
              TextField(

                controller:
                    passwordController,

                obscureText:
                    isObscure,

                decoration:
                    InputDecoration(

                  labelText:
                      'Password',

                  border:
                      const OutlineInputBorder(),

                  suffixIcon:
                      IconButton(

                    icon: Icon(
                      isObscure
                          ? Icons.visibility
                          : Icons.visibility_off,
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

              // ================= BUTTON LOGIN =================
              SizedBox(

                width:
                    double.infinity,

                child: ElevatedButton(

                  onPressed:
                      isLoading
                          ? null
                          : _login,

                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Masuk',
                            ),
                ),
              ),

              // ================= LUPA PASSWORD =================
              TextButton(

                onPressed: () {},

                child: const Text(
                  'Lupa password',
                ),
              ),

              const SizedBox(height: 10),

              // ================= DAFTAR =================
              Row(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  const Text(
                    "Belum punya akun?",
                  ),

                  TextButton(

                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DaftarAkun(),
                        ),
                      );
                    },

                    child: const Text(
                      "Daftar",
                    ),
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