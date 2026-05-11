import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilPage extends StatefulWidget {
  final String username;
  final String marhalah;

  const ProfilPage({
    super.key,
    required this.username,
    required this.marhalah,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {

  final supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController =
      TextEditingController();

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  File? _imageFile;

  String? fotoUrl;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadProfil();
  }

  // ================= LOAD DATA =================
  Future<void> _loadProfil() async {

    try {

      final data = await supabase
          .from('pembimbing')
          .select()
          .eq('username', widget.username)
          .single();

      _namaController.text =
          data['nama_lengkap'] ?? '';

      _usernameController.text =
          data['username'] ?? '';

      _passwordController.text =
          data['password'] ?? '';

      fotoUrl = data['foto_url'];

      setState(() {});

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal load profil: $e',
          ),
        ),
      );
    }
  }

  // ================= PILIH FOTO =================
  Future<void> _pickImage() async {

    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {

      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // ================= UPLOAD FOTO =================
  Future<String?> _uploadFoto() async {

    if (_imageFile == null) {
      return fotoUrl;
    }

    try {

      final fileName =
          'profil_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage
          .from('avatars')
          .upload(
            fileName,
            _imageFile!,
          );

      final publicUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      return publicUrl;

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Upload foto gagal: $e',
          ),
        ),
      );

      return null;
    }
  }

  // ================= SIMPAN =================
  Future<void> _saveProfile() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final fotoBaru = await _uploadFoto();

      await supabase
          .from('pembimbing')
          .update({

        'nama_lengkap':
            _namaController.text.trim(),

        'username':
            _usernameController.text
                .trim()
                .toLowerCase(),

        'password':
            _passwordController.text.trim(),

        'foto_url': fotoBaru,

      })
          .eq(
            'username',
            widget.username,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profil berhasil diperbarui',
          ),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal update profil: $e',
          ),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Profil Pembimbing",
        ),
        backgroundColor: Colors.lime[400],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Form(

          key: _formKey,

          child: Column(
            children: [

              // ================= FOTO =================
              GestureDetector(
                onTap: _pickImage,

                child: CircleAvatar(

                  radius: 55,

                  backgroundColor:
                      Colors.grey[300],

                  backgroundImage:
                      _imageFile != null

                          ? FileImage(_imageFile!)

                          : fotoUrl != null
                              ? NetworkImage(fotoUrl!)
                              : null
                                  as ImageProvider?,

                  child:
                      _imageFile == null &&
                              fotoUrl == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 40,
                            )
                          : null,
                ),
              ),

              const SizedBox(height: 24),

              // ================= NAMA =================
              TextFormField(

                controller:
                    _namaController,

                decoration:
                    const InputDecoration(
                  labelText: "Nama Lengkap",
                  border:
                      OutlineInputBorder(),
                ),

                validator: (value) {

                  if (value == null ||
                      value.isEmpty) {

                    return 'Nama tidak boleh kosong';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ================= USERNAME =================
              TextFormField(

                controller:
                    _usernameController,

                decoration:
                    const InputDecoration(
                  labelText: "Username",
                  border:
                      OutlineInputBorder(),
                ),

                validator: (value) {

                  if (value == null ||
                      value.isEmpty) {

                    return 'Username tidak boleh kosong';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ================= PASSWORD =================
              TextFormField(

                controller:
                    _passwordController,

                obscureText: true,

                decoration:
                    const InputDecoration(
                  labelText: "Password",
                  border:
                      OutlineInputBorder(),
                ),

                validator: (value) {

                  if (value == null ||
                      value.isEmpty) {

                    return 'Password tidak boleh kosong';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ================= BUTTON =================
              SizedBox(

                width: double.infinity,

                child: ElevatedButton.icon(

                  onPressed:
                      isLoading
                          ? null
                          : _saveProfile,

                  icon: const Icon(
                    Icons.save,
                  ),

                  label:
                      isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Simpan Perubahan",
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