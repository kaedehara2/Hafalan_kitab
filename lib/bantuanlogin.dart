import 'package:flutter/material.dart';
import 'resetakunpembimbing.dart';

class BantuanLoginPage extends StatefulWidget {
  const BantuanLoginPage({super.key});

  @override
  State<BantuanLoginPage> createState() =>
      _BantuanLoginPageState();
}

class _BantuanLoginPageState
    extends State<BantuanLoginPage> {

  String selectedRole = '';

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[200],

      appBar: AppBar(

        title: const Text(
          'Bantuan Login',
        ),

        backgroundColor: Colors.lime[400],
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ================= TITLE =================
            const Text(

              'Pilih Jenis Akun',

              style: TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(

              'Silakan pilih jenis akun untuk proses bantuan login.',

              style: TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            // ================= PEMBIMBING =================
            Card(

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: RadioListTile(

                value: 'Pembimbing',

                groupValue: selectedRole,

                title: const Text(
                  'Pembimbing',
                ),

                secondary: const Icon(
                  Icons.school,
                  color: Colors.green,
                ),

                onChanged: (value) {

                  setState(() {

                    selectedRole = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // ================= ADMIN =================
            Card(

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: RadioListTile(

                value: 'Admin',

                groupValue: selectedRole,

                title: const Text(
                  'Admin',
                ),

                secondary: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.orange,
                ),

                onChanged: (value) {

                  setState(() {

                    selectedRole = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // ================= WALI SANTRI =================
            Card(

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: RadioListTile(

                value: 'Wali Santri',

                groupValue: selectedRole,

                title: const Text(
                  'Wali Santri',
                ),

                secondary: const Icon(
                  Icons.family_restroom,
                  color: Colors.blue,
                ),

                onChanged: (value) {

                  setState(() {

                    selectedRole = value!;
                  });
                },
              ),
            ),

            const Spacer(),

            // ================= BUTTON =================
            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.lime[400],

                  foregroundColor:
                      Colors.black,

                  shape: RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),

                onPressed: () {

                  // ================= VALIDASI =================
                  if (selectedRole.isEmpty) {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      const SnackBar(

                        content: Text(
                          'Silakan pilih jenis akun',
                        ),
                      ),
                    );

                    return;
                  }

                 // ================= PEMBIMBING =================
                  if (selectedRole ==
                      'Pembimbing') {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const ResetAkunPembimbingPage(),
                      ),
                    );
                  }

                  // ================= ADMIN =================
                  else if (selectedRole ==
                      'Admin') {

                    showDialog(

                      context: context,

                      builder: (_) {

                        return AlertDialog(

                          title: const Text(
                            'Bantuan Admin',
                          ),

                          content: const Text(
                            'Silakan hubungi developer untuk pemulihan akun admin.',
                          ),

                          actions: [

                            TextButton(

                              onPressed: () {

                                Navigator.pop(
                                    context);
                              },

                              child: const Text(
                                'Tutup',
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }

                  // ================= WALI =================
                  else if (selectedRole ==
                      'Wali Santri') {

                    showDialog(

                      context: context,

                      builder: (_) {

                        return AlertDialog(

                          title: const Text(
                            'Bantuan Wali Santri',
                          ),

                          content: const Text(
                            'Silakan hubungi developer untuk bantuan login wali santri.',
                          ),

                          actions: [

                            TextButton(

                              onPressed: () {

                                Navigator.pop(
                                    context);
                              },

                              child: const Text(
                                'Tutup',
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },

                child: const Text(

                  'Lanjutkan',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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