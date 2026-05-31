import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'resetakunpembimbing.dart';

class BantuanLoginPage extends StatefulWidget {

  const BantuanLoginPage({
    super.key,
  });

  @override
  State<BantuanLoginPage> createState() =>
      _BantuanLoginPageState();
}

class _BantuanLoginPageState
    extends State<BantuanLoginPage> {

  String selectedRole = '';

  // ================= WHATSAPP =================
Future<void> bukaWhatsApp({
  required String pesan,
}) async {
  final nomorDeveloper = '62895398355567';

  final Uri whatsappApp = Uri.parse(
    'whatsapp://send?phone=$nomorDeveloper&text=${Uri.encodeComponent(pesan)}',
  );

  final Uri whatsappWeb = Uri.parse(
    'https://wa.me/$nomorDeveloper?text=${Uri.encodeComponent(pesan)}',
  );

  try {
    if (await canLaunchUrl(whatsappApp)) {
      await launchUrl(
        whatsappApp,
        mode: LaunchMode.externalApplication,
      );
    } else {
      await launchUrl(
        whatsappWeb,
        mode: LaunchMode.externalApplication,
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Gagal membuka WhatsApp',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[200],

      appBar: AppBar(

        title: const Text(
          'Bantuan Login',
        ),

        backgroundColor:
            Colors.lime[400],
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            // ================= TITLE =================
            const Text(

              'Pilih Jenis Akun',

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,
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

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                        18),
              ),

              child: RadioListTile(

                value: 'Pembimbing',

                groupValue:
                    selectedRole,

                title: const Text(
                  'Pembimbing',
                ),

                secondary:
                    const Icon(

                  Icons.school,

                  color:
                      Colors.green,
                ),

                onChanged: (value) {

                  setState(() {

                    selectedRole =
                        value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // ================= ADMIN =================
            Card(

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                        18),
              ),

              child: RadioListTile(

                value: 'Admin',

                groupValue:
                    selectedRole,

                title: const Text(
                  'Admin',
                ),

                secondary:
                    const Icon(

                  Icons
                      .admin_panel_settings,

                  color:
                      Colors.orange,
                ),

                onChanged: (value) {

                  setState(() {

                    selectedRole =
                        value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // ================= WALI SANTRI =================
            Card(

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                        18),
              ),

              child: RadioListTile(

                value: 'Wali Santri',

                groupValue:
                    selectedRole,

                title: const Text(
                  'Wali Santri',
                ),

                secondary:
                    const Icon(

                  Icons
                      .family_restroom,

                  color:
                      Colors.blue,
                ),

                onChanged: (value) {

                  setState(() {

                    selectedRole =
                        value!;
                  });
                },
              ),
            ),

            const Spacer(),

            // ================= BUTTON =================
            SizedBox(

              width:
                  double.infinity,

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

                onPressed: () {

                  // ================= VALIDASI =================
                  if (selectedRole
                      .isEmpty) {

                    ScaffoldMessenger.of(
                            context)
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

                    bukaWhatsApp(

                      pesan:
                          'Assalamu\'alaikum developer, saya admin aplikasi Hafalku mengalami lupa username/password dan membutuhkan bantuan pemulihan akun.',
                    );
                  }

                  // ================= WALI SANTRI =================
                  else if (selectedRole ==
                      'Wali Santri') {

                    bukaWhatsApp(

                      pesan:
                          'Assalamu\'alaikum developer, saya wali santri aplikasi Hafalku mengalami lupa username/password dan membutuhkan bantuan login.',
                    );
                  }
                },

                child: const Text(

                  'Lanjutkan',

                  style: TextStyle(

                    fontSize: 16,

                    fontWeight:
                        FontWeight.bold,
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