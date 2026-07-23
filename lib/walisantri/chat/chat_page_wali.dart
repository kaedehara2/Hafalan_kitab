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
      debugPrint("========== LOAD CHAT ==========");

      // ================= CARI SANTRI =================
      final santriData = await supabase
          .from('santri')
          .select()
          .eq('wali_id', int.parse(widget.waliId))
          .maybeSingle();

      if (santriData == null) {
        debugPrint("SANTRI TIDAK DITEMUKAN");

        setState(() {
          isLoading = false;
        });
        return;
      }

      debugPrint("SANTRI : $santriData");

      // ================= CARI ROOM =================
      final roomList = await supabase
          .from('chat_rooms')
          .select()
          .eq('santri_id', santriData['id'])
          .order('id', ascending: false);

      Map<String, dynamic>? room;

      if (roomList.isNotEmpty) {
        room = Map<String, dynamic>.from(roomList.first);
      }

      debugPrint("ROOM : $room");

      Map<String, dynamic>? pembimbingData;

      if (room != null) {
        roomId = room['id'];

        pembimbingData = await supabase
            .from('pembimbing')
            .select()
            .eq('id', room['pembimbing_id'])
            .maybeSingle();

        debugPrint("PEMBIMBING DARI ROOM : $pembimbingData");
      } else {
        debugPrint("ROOM BELUM ADA");

        final pembimbingList = await supabase
            .from('pembimbing')
            .select()
            .eq('marhalah', santriData['marhalah']);

        if (pembimbingList.isEmpty) {
          debugPrint("PEMBIMBING SESUAI MARHALAH TIDAK ADA");

          setState(() {
            isLoading = false;
          });

          return;
        }

        pembimbingData =
            Map<String, dynamic>.from(pembimbingList.first);

        roomId = await chatService.getOrCreateRoom(
          waliId: int.parse(widget.waliId),
          pembimbingId: pembimbingData['id'].toString(),
          santriId: santriData['id'],
        );

        debugPrint("ROOM BARU : $roomId");
      }

      debugPrint("ROOM ID : $roomId");
      debugPrint("PEMBIMBING : $pembimbingData");

      if (!mounted) return;

      setState(() {
        santri = Map<String, dynamic>.from(santriData);
        pembimbing = pembimbingData;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR CHAT WALI : $e");

      if (!mounted) return;

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
          namaPembimbing: pembimbing!['nama_lengkap'],
          namaSantri: santri!['nama_lengkap'],
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 70,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pembimbing!['nama_lengkap'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pembimbing!['marhalah'],
                          ),
                          const Divider(height: 32),
                          Text(
                            'Santri: ${santri!['nama_lengkap']}',
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: bukaPercakapan,
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