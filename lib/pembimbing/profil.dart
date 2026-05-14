import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilPage extends StatefulWidget {

  final String idPembimbing;
  final String username;
  final String marhalah;

  const ProfilPage({
    super.key,
    required this.idPembimbing,
    required this.username,
    required this.marhalah,
  });

  @override
  State<ProfilPage> createState() =>
      _ProfilPageState();
}

class _ProfilPageState
    extends State<ProfilPage> {

  final supabase =
      Supabase.instance.client;

  final _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _namaController =
      TextEditingController();

  final TextEditingController
      _usernameController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();

  bool isLoading = true;

  bool isSaving = false;

  bool isObscure = true;

  @override
  void initState() {
    super.initState();

    _loadProfil();
  }

  // ================= LOAD PROFIL =================
  Future<void> _loadProfil() async {

    try {

      final data =
          await supabase
              .from('pembimbing')
              .select()
              .eq(
                'id',
                widget.idPembimbing,
              )
              .maybeSingle();

      if (data != null) {

        _namaController.text =
            data['nama_lengkap'] ?? '';

        _usernameController.text =
            data['username'] ?? '';

        _passwordController.text =
            data['password'] ?? '';
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal load profil: $e',
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================= SAVE =================
  Future<void> _saveProfile() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      await supabase
          .from('pembimbing')
          .update({

        'nama_lengkap':
            _namaController.text
                .trim(),

        'username':
            _usernameController
                .text
                .trim()
                .toLowerCase(),

        'password':
            _passwordController
                .text
                .trim(),

      }).eq(
        'id',
        widget.idPembimbing,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profil berhasil diperbarui',
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal update profil: $e',
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
          'Profil Pembimbing',
        ),
        backgroundColor:
            Colors.lime[400],
      ),

      body:
          SingleChildScrollView(

        padding:
            const EdgeInsets.all(
                16),

        child: Form(

          key: _formKey,

          child: Column(
            children: [

              CircleAvatar(
                radius: 55,
                backgroundColor:
                    Colors.lime[300],
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.black,
                ),
              ),

              const SizedBox(
                  height: 24),

              // ================= NAMA =================
              TextFormField(

                controller:
                    _namaController,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Nama Lengkap',
                  border:
                      OutlineInputBorder(),
                ),

                validator:
                    (value) {

                  if (value == null ||
                      value.isEmpty) {

                    return 'Nama lengkap wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(
                  height: 16),

              // ================= USERNAME =================
              TextFormField(

                controller:
                    _usernameController,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Username',
                  border:
                      OutlineInputBorder(),
                ),

                validator:
                    (value) {

                  if (value == null ||
                      value.isEmpty) {

                    return 'Username wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(
                  height: 16),

              // ================= PASSWORD =================
              TextFormField(

                controller:
                    _passwordController,

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

                        isObscure =
                            !isObscure;
                      });
                    },
                  ),
                ),

                validator:
                    (value) {

                  if (value == null ||
                      value.isEmpty) {

                    return 'Password wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(
                  height: 24),

              // ================= BUTTON =================
              SizedBox(

                width:
                    double.infinity,

                child:
                    ElevatedButton.icon(

                  onPressed:
                      isSaving
                          ? null
                          : _saveProfile,

                  icon:
                      const Icon(
                    Icons.save,
                  ),

                  label:
                      isSaving
                          ? const CircularProgressIndicator(
                              color:
                                  Colors.white,
                            )
                          : const Text(
                              'Simpan Perubahan',
                            ),

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        Colors.lime[400],

                    foregroundColor:
                        Colors.black,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}