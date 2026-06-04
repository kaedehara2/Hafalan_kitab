import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/chat/chat_service.dart';
import '../../shared/chat/chat_room_page.dart';

class ChatPageWali extends StatefulWidget {
  final String waliId;
  final String namaWali;

  const ChatPageWali({
    super.key,
    required this.waliId,
    required this.namaWali,
  });

  @override
  State<ChatPageWali> createState() => _ChatPageWaliState();
}

class _ChatPageWaliState extends State<ChatPageWali> {
  final supabase = Supabase.instance.client;
  final chatService = ChatService();

  bool isLoading = true;

  Map<String, dynamic>? santri;
  Map<String, dynamic>? pembimbing;

  int? roomId;

  @override
  void initState() {
    super.initState();
    loadChatData();
  }

  Future<void> loadChatData() async {
    try {
      // Cari santri berdasarkan wali
      final santriData = await supabase
          .from('santri')
          .select()
          .eq('wali_id', int.parse(widget.waliId))
          .single();

      // Cari pembimbing berdasarkan marhalah
      final pembimbingData = await supabase
          .from('pembimbing')
          .select()
          .eq('marhalah', santriData['marhalah'])
          .single();

      // Cari / buat room
      final room = await chatService.getOrCreateRoom(
        waliId: int.parse(widget.waliId),
        pembimbingId: pembimbingData['id'],
        santriId: santriData['id'],
      );

      setState(() {
        santri = santriData;
        pembimbing = pembimbingData;
        roomId = room;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error Chat Wali: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  void bukaPercakapan() {
    if (roomId == null ||
        pembimbing == null ||
        santri == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(
          roomId: roomId!,
          namaPembimbing:
              pembimbing!['nama_lengkap'],
          namaSantri:
              santri!['nama_lengkap'],
          senderRole: 'wali',
          senderId: widget.waliId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Pembimbing'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : pembimbing == null
              ? const Center(
                  child: Text(
                    'Pembimbing tidak ditemukan',
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 70,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            pembimbing![
                                'nama_lengkap'],
                            style:
                                const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            pembimbing![
                                'marhalah'],
                          ),
                          const Divider(
                            height: 32,
                          ),
                          Text(
                            'Santri: ${santri!['nama_lengkap']}',
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width:
                                double.infinity,
                            child:
                                ElevatedButton(
                              onPressed:
                                  bukaPercakapan,
                              child: const Text(
                                'Buka Percakapan',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}