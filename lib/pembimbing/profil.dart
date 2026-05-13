import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  String? _fotoProfil;

  bool isLoading = true;

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
          .eq('id', widget.idPembimbing)
          .maybeSingle();

      if (data == null) return;

      setState(() {
        _namaController.text =
            data['nama_lengkap'] ?? '';

        _usernameController.text =
            data['username'] ?? '';

        _passwordController.text =
            data['password'] ?? '';

        _fotoProfil =
            data['foto_profil'];

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Gagal load profil: $e"),
        ),
      );
    }
  }

  // ================= PILIH FOTO =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _imageFile =
            File(image.path);
      });
    }
  }

  // ================= UPLOAD FOTO =================
  Future<String?> _uploadFoto() async {
    if (_imageFile == null) return _fotoProfil;

    try {
      final fileName =
          '${widget.idPembimbing}.jpg';

      await supabase.storage
          .from('avatars')
          .upload(
            fileName,
            _imageFile!,
            fileOptions:
                const FileOptions(
              upsert: true,
            ),
          );

      final publicUrl = supabase
          .storage
          .from('avatars')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Upload gagal: $e"),
        ),
      );

      return null;
    }
  }

  // ================= SAVE =================
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!
        .validate()) return;

    try {
      final fotoBaru =
          await _uploadFoto();

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
            _passwordController.text
                .trim(),

        'foto_profil':
            fotoBaru,
      }).eq(
        'id',
        widget.idPembimbing,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Profil berhasil diperbarui",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Gagal update: $e"),
        ),
      );
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
            const Text("Profil"),
        backgroundColor:
            Colors.lime[400],
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,

                  backgroundImage:
                      _imageFile != null
                          ? FileImage(
                              _imageFile!,
                            )
                          : (_fotoProfil != null
                              ? NetworkImage(
                                  _fotoProfil!,
                                )
                              : null)
                          as ImageProvider?,

                  child:
                      _imageFile == null &&
                              _fotoProfil ==
                                  null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 40,
                            )
                          : null,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              TextFormField(
                controller:
                    _namaController,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Nama Lengkap",
                  border:
                      OutlineInputBorder(),
                ),
                validator:
                    (v) => v!.isEmpty
                        ? "Wajib"
                        : null,
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _usernameController,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Username",
                  border:
                      OutlineInputBorder(),
                ),
                validator:
                    (v) => v!.isEmpty
                        ? "Wajib"
                        : null,
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _passwordController,
                obscureText: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Password",
                  border:
                      OutlineInputBorder(),
                ),
                validator:
                    (v) => v!.isEmpty
                        ? "Wajib"
                        : null,
              ),

              const SizedBox(
                height: 24,
              ),

              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _saveProfile,
                  icon:
                      const Icon(
                    Icons.save,
                  ),
                  label:
                      const Text(
                    "Simpan Perubahan",
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.lime[400],
                    foregroundColor:
                        Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}