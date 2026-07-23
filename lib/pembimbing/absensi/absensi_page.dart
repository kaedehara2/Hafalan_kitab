import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AbsensiPage extends StatefulWidget {

  final String marhalah;

  const AbsensiPage({
    super.key,
    required this.marhalah,
  });

  @override
  State<AbsensiPage> createState() =>
      _AbsensiPageState();
}

class _AbsensiPageState
    extends State<AbsensiPage> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  List<Map<String,dynamic>> santri = [];

  @override
  void initState() {
    super.initState();
    loadSantri();
  }

  Future<void> loadSantri() async {

    try {

      final data = await supabase
          .from('santri')
          .select()
          .eq('marhalah', widget.marhalah)
          .order('nama_lengkap');

      setState(() {

        santri =
            List<Map<String,dynamic>>
                .from(data);

        loading = false;

      });

    } catch(e){

      debugPrint(e.toString());

      setState(() {

        loading = false;

      });

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Absensi Santri",
        ),

        backgroundColor: Colors.lime,

      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : ListView.builder(

              itemCount: santri.length,

              itemBuilder: (_,index){

                final s = santri[index];

                return Card(

                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  child: ListTile(

                    leading:
                        const CircleAvatar(

                      child: Icon(Icons.person),

                    ),

                    title: Text(
                      s['nama_lengkap'],
                    ),

                    subtitle: Text(
                      "Kelas ${s['kelas']} • ${s['jenjang']}",
                    ),

                  ),

                );

              },

            ),

    );

  }

}