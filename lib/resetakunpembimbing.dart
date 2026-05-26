import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetAkunPembimbingPage
    extends StatefulWidget {

  const ResetAkunPembimbingPage({
    super.key,
  });

  @override
  State<ResetAkunPembimbingPage>
      createState() =>
          _ResetAkunPembimbingPageState();
}

class _ResetAkunPembimbingPageState
    extends State<ResetAkunPembimbingPage> {

  final supabase =
      Supabase.instance.client;

  final usernameController =
      TextEditingController();

  final passwordBaruController =
      TextEditingController();

  final konfirmasiPasswordController =
      TextEditingController();

  String selectedMarhalah = '';

  bool isPasswordVisible = false;

  bool isKonfirmasiVisible = false;

  bool isLoading = false;

  // ================= RESET AKUN =================
  Future<void> resetAkun() async {

    // ================= VALIDASI KOSONG =================
    if (usernameController.text.isEmpty ||
        selectedMarhalah.isEmpty ||
        passwordBaruController
            .text.isEmpty ||
        konfirmasiPasswordController
            .text.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            'Semua data wajib diisi',
          ),
        ),
      );

      return;
    }

    // ================= PASSWORD TIDAK SAMA =================
    if (passwordBaruController.text !=
        konfirmasiPasswordController
            .text) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            'Konfirmasi password tidak sama',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      // ================= CEK AKUN =================
      final data = await supabase

          .from('pembimbing')

          .select()

          .eq(
            'username',
            usernameController.text,
          )

          .eq(
            'marhalah',
            selectedMarhalah,
          )

          .maybeSingle();

      // ================= AKUN TIDAK DITEMUKAN =================
      if (data == null) {

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              'Akun pembimbing tidak ditemukan',
            ),
          ),
        );

        return;
      }

      // ================= UPDATE PASSWORD =================
      await supabase

          .from('pembimbing')

          .update({

            'password':
                passwordBaruController
                    .text,
          })

          .eq(
            'username',
            usernameController.text,
          );

      setState(() {
        isLoading = false;
      });

      // ================= DIALOG BERHASIL =================
      showDialog(

        context: context,

        builder: (_) {

          return AlertDialog(

            title: const Text(
              'Reset Berhasil',
            ),

            content: Column(

              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                const Text(
                  'Akun pembimbing berhasil diperbarui.',
                ),

                const SizedBox(
                    height: 12),

                Text(
                  'Username: ${data['username']}',
                ),
              ],
            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(context);

                  Navigator.pop(context);
                },

                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            'Terjadi kesalahan: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[200],

      appBar: AppBar(

        title: const Text(
          'Reset Akun Pembimbing',
        ),

        backgroundColor:
            Colors.lime[400],
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ================= TITLE =================
            const Text(

              'Pemulihan Akun Pembimbing',

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(

              'Silakan isi data berikut untuk melakukan reset akun pembimbing.',

              style: TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            // ================= USERNAME =================
            TextField(

              controller:
                  usernameController,

              decoration:
                  InputDecoration(

                labelText:
                    'Username',

                prefixIcon:
                    const Icon(
                  Icons.person,
                ),

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius
                          .circular(
                              18),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= MARHALAH =================
            DropdownButtonFormField<String>(

              value:
                  selectedMarhalah
                          .isEmpty
                      ? null
                      : selectedMarhalah,

              items: const [

                DropdownMenuItem(

                  value:
                      'Marhalah 1',

                  child: Text(
                    'Marhalah 1',
                  ),
                ),

                DropdownMenuItem(

                  value:
                      'Marhalah 2',

                  child: Text(
                    'Marhalah 2',
                  ),
                ),

                DropdownMenuItem(

                  value:
                      'Marhalah 3',

                  child: Text(
                    'Marhalah 3',
                  ),
                ),

                DropdownMenuItem(

                  value:
                      'Marhalah 4',

                  child: Text(
                    'Marhalah 4',
                  ),
                ),
              ],

              onChanged: (value) {

                setState(() {

                  selectedMarhalah =
                      value!;
                });
              },

              decoration:
                  InputDecoration(

                labelText:
                    'Pilih Marhalah',

                prefixIcon:
                    const Icon(
                  Icons.school,
                ),

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius
                          .circular(
                              18),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= PASSWORD BARU =================
            TextField(

              controller:
                  passwordBaruController,

              obscureText:
                  !isPasswordVisible,

              decoration:
                  InputDecoration(

                labelText:
                    'Password Baru',

                prefixIcon:
                    const Icon(
                  Icons.lock,
                ),

                suffixIcon:
                    IconButton(

                  icon: Icon(

                    isPasswordVisible

                        ? Icons
                            .visibility

                        : Icons
                            .visibility_off,
                  ),

                  onPressed: () {

                    setState(() {

                      isPasswordVisible =
                          !isPasswordVisible;
                    });
                  },
                ),

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius
                          .circular(
                              18),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= KONFIRMASI PASSWORD =================
            TextField(

              controller:
                  konfirmasiPasswordController,

              obscureText:
                  !isKonfirmasiVisible,

              decoration:
                  InputDecoration(

                labelText:
                    'Konfirmasi Password',

                prefixIcon:
                    const Icon(
                  Icons.lock_outline,
                ),

                suffixIcon:
                    IconButton(

                  icon: Icon(

                    isKonfirmasiVisible

                        ? Icons
                            .visibility

                        : Icons
                            .visibility_off,
                  ),

                  onPressed: () {

                    setState(() {

                      isKonfirmasiVisible =
                          !isKonfirmasiVisible;
                    });
                  },
                ),

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius
                          .circular(
                              18),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ================= BUTTON =================
            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton(

                style:
                    ElevatedButton
                        .styleFrom(

                  backgroundColor:
                      Colors.lime[400],

                  foregroundColor:
                      Colors.black,

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius
                            .circular(
                                18),
                  ),
                ),

                onPressed:
                    isLoading
                        ? null
                        : resetAkun,

                child:
                    isLoading

                        ? const CircularProgressIndicator(
                            color:
                                Colors.black,
                          )

                        : const Text(

                            'Reset Akun',

                            style: TextStyle(

                              fontSize: 16,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}