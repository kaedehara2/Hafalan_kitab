import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/chat/chat_room_page.dart';

class ChatListPembimbingPage extends StatefulWidget {
  final String idPembimbing;

  const ChatListPembimbingPage({
    super.key,
    required this.idPembimbing,
  });

  @override
  State<ChatListPembimbingPage> createState() =>
      _ChatListPembimbingPageState();
}

class _ChatListPembimbingPageState
    extends State<ChatListPembimbingPage> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  List<Map<String, dynamic>>
      daftarRoom = [];

  @override
  void initState() {
    super.initState();

    loadRooms();
  }

  Future<void> loadRooms() async {

    try {

      final rooms = await supabase

          .from('chat_rooms')

          .select()

          .eq(
            'pembimbing_id',
            widget.idPembimbing,
          );

      List<Map<String, dynamic>>
          hasil = [];

      for (final room in rooms) {

        final wali =
            await supabase

                .from('wali_santri')

                .select()

                .eq(
                  'id',
                  room['wali_id'],
                )

                .single();

        final santri =
            await supabase

                .from('santri')

                .select()

                .eq(
                  'id',
                  room['santri_id'],
                )

                .single();

        hasil.add({

          'room_id':
              room['id'],

          'nama_wali':
              wali['nama_wali'],

          'nama_santri':
              santri['nama_lengkap'],
        });
      }

      if (!mounted) return;

      setState(() {

        daftarRoom = hasil;

        loading = false;
      });

    } catch (e) {

      debugPrint(
        'Error load rooms: $e',
      );

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Chat Wali Santri',
        ),
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : daftarRoom.isEmpty

              ? const Center(

                  child: Text(
                    'Belum ada chat masuk',
                  ),
                )

              : ListView.builder(

                  itemCount:
                      daftarRoom.length,

                  itemBuilder:
                      (context, index) {

                    final room =
                        daftarRoom[index];

                    return Card(

                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      child: ListTile(

                        leading:
                            const CircleAvatar(
                          child: Icon(
                            Icons.person,
                          ),
                        ),

                        title: Text(
                          room['nama_wali'],
                        ),

                        subtitle: Text(
                          'Santri: ${room['nama_santri']}',
                        ),

                        trailing:
                            const Icon(
                          Icons.chevron_right,
                        ),

                        onTap: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                                  ChatRoomPage(

                                roomId:
                                    room['room_id'],

                                namaPembimbing:
                                    'Pembimbing',

                                namaSantri:
                                    room['nama_santri'],

                                senderRole:
                                    'pembimbing',

                                senderId:
                                    widget.idPembimbing,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}