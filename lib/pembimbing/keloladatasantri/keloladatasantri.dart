import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaDataSantri extends StatefulWidget {
  const KelolaDataSantri({super.key});

  @override
  State<KelolaDataSantri> createState() => _KelolaDataSantriState();
}

class _KelolaDataSantriState extends State<KelolaDataSantri> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> santriList = [];

  // ================= CONTROLLER =================
  final TextEditingController namaController = TextEditingController();
  final TextEditingController kelasController = TextEditingController();
  final TextEditingController jenjangController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController waliController = TextEditingController();

  int? editingId;

  @override
  void initState() {
    super.initState();
    _fetchSantri();
  }

  // ================= FETCH =================
  Future<void> _fetchSantri() async {
    final response =
        await supabase.from('santri').select().order('id', ascending: true);

    setState(() {
      santriList = List<Map<String, dynamic>>.from(response);
    });
  }

  // ================= ADD =================
  Future<void> _addSantri() async {
    final nama = namaController.text.trim();
    final alamat = alamatController.text.trim();
    final wali = waliController.text.trim();
    final jenjang = jenjangController.text.trim();
    final kelas = int.tryParse(kelasController.text.trim());

    if (nama.isEmpty ||
        alamat.isEmpty ||
        wali.isEmpty ||
        jenjang.isEmpty ||
        kelas == null) {
      _showError();
      return;
    }

    await supabase.from('santri').insert({
      'nama_lengkap': nama,
      'kelas': kelas,
      'jenjang': jenjang,
      'alamat': alamat,
      'nama_wali': wali,
    });

    _afterSave('Data berhasil ditambahkan');
  }

  // ================= UPDATE =================
  Future<void> _updateSantri() async {
    if (editingId == null) return;

    final nama = namaController.text.trim();
    final alamat = alamatController.text.trim();
    final wali = waliController.text.trim();
    final jenjang = jenjangController.text.trim();
    final kelas = int.tryParse(kelasController.text.trim());

    if (nama.isEmpty ||
        alamat.isEmpty ||
        wali.isEmpty ||
        jenjang.isEmpty ||
        kelas == null) {
      _showError();
      return;
    }

    await supabase.from('santri').update({
      'nama_lengkap': nama,
      'kelas': kelas,
      'jenjang': jenjang,
      'alamat': alamat,
      'nama_wali': wali,
    }).eq('id', editingId!);

    _afterSave('Data berhasil diperbarui');
  }

  // ================= DELETE =================
  Future<void> _deleteSantri(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('santri').delete().eq('id', id);
      await _fetchSantri();
    }
  }

  // ================= MODAL =================
  void _showAddSantriModal() {
    _clearForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _buildFormModal('Tambah Data Santri', _addSantri),
    );
  }

  void _showEditSantriModal(Map<String, dynamic> santri) {
    namaController.text = santri['nama_lengkap'] ?? '';
    kelasController.text = santri['kelas'].toString();
    jenjangController.text = santri['jenjang'] ?? '';
    alamatController.text = santri['alamat'] ?? '';
    waliController.text = santri['nama_wali'] ?? '';
    editingId = santri['id'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _buildFormModal('Edit Data Santri', _updateSantri),
    );
  }

  Widget _buildFormModal(String title, Future<void> Function() onSave) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Wrap(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          _input(namaController, 'Nama Lengkap'),
          const SizedBox(height: 12),

          TextField(
            controller: kelasController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Kelas (angka)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          _input(jenjangController, 'Jenjang (SMP / SMA)'),
          const SizedBox(height: 12),

          _input(alamatController, 'Alamat'),
          const SizedBox(height: 12),

          _input(waliController, 'Nama Orang Tua / Wali'),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lime[600],
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ================= HELPER =================
  Widget _input(TextEditingController c, String label) => TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      );

  void _afterSave(String message) async {
    _clearForm();
    Navigator.pop(context);
    await _fetchSantri();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearForm() {
    namaController.clear();
    kelasController.clear();
    jenjangController.clear();
    alamatController.clear();
    waliController.clear();
    editingId = null;
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua field wajib diisi & kelas harus angka')),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Data Santri'),
        backgroundColor: Colors.lime[400],
      ),
      body: santriList.isEmpty
          ? const Center(child: Text('Belum ada data santri'))
          : ListView.builder(
              itemCount: santriList.length,
              itemBuilder: (_, index) {
                final s = santriList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(s['nama_lengkap']),
                    subtitle: Text(
                        'Kelas ${s['kelas']} ${s['jenjang']} • ${s['alamat']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditSantriModal(s),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSantri(s['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lime[600],
        onPressed: _showAddSantriModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
