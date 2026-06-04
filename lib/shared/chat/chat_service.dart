import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final supabase = Supabase.instance.client;

  /// Cari room yang sudah ada
  Future<Map<String, dynamic>?> getRoom({
    required int waliId,
    required String pembimbingId,
    required int santriId,
  }) async {
    final room = await supabase
        .from('chat_rooms')
        .select()
        .eq('wali_id', waliId)
        .eq('pembimbing_id', pembimbingId)
        .eq('santri_id', santriId)
        .maybeSingle();

    return room;
  }

  /// Buat room baru jika belum ada
  Future<Map<String, dynamic>> createRoom({
    required int waliId,
    required String pembimbingId,
    required int santriId,
  }) async {
    final result = await supabase
        .from('chat_rooms')
        .insert({
          'wali_id': waliId,
          'pembimbing_id': pembimbingId,
          'santri_id': santriId,
        })
        .select()
        .single();

    return result;
  }

  /// Cari room atau buat baru
  Future<int> getOrCreateRoom({
    required int waliId,
    required String pembimbingId,
    required int santriId,
  }) async {
    final room = await getRoom(
      waliId: waliId,
      pembimbingId: pembimbingId,
      santriId: santriId,
    );

    if (room != null) {
      return room['id'];
    }

    final newRoom = await createRoom(
      waliId: waliId,
      pembimbingId: pembimbingId,
      santriId: santriId,
    );

    return newRoom['id'];
  }

  /// Ambil semua pesan
  Future<List<dynamic>> getMessages(int roomId) async {
    final messages = await supabase
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at');

    return messages;
  }

  /// Kirim pesan
  Future<void> sendMessage({
    required int roomId,
    required String senderRole,
    required String senderId,
    required String message,
  }) async {
    await supabase.from('chat_messages').insert({
      'room_id': roomId,
      'sender_role': senderRole,
      'sender_id': senderId,
      'message': message,
    });
  }

  /// Realtime listener
  RealtimeChannel subscribeMessages({
    required int roomId,
    required Function(Map<String, dynamic>) onNewMessage,
  }) {
    return supabase
        .channel('chat_room_$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            onNewMessage(payload.newRecord);
          },
        )
        .subscribe();
  }
}