import 'package:flutter/material.dart';

import 'chat_service.dart';

class ChatRoomPage extends StatefulWidget {
  final int roomId;
  final String namaPembimbing;
  final String namaSantri;
  final String senderRole;
  final String senderId;

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.namaPembimbing,
    required this.namaSantri,
    required this.senderRole,
    required this.senderId,
  });

  @override
  State<ChatRoomPage> createState() =>
      _ChatRoomPageState();
}

class _ChatRoomPageState
    extends State<ChatRoomPage> {
  final ChatService chatService =
      ChatService();

  final TextEditingController
      messageController =
      TextEditingController();

  List<dynamic> messages = [];

  bool isLoading = true;

  dynamic channel;

  @override
  void initState() {
    super.initState();

    loadMessages();

    listenRealtime();
  }

  Future<void> loadMessages() async {
    try {
      final data =
          await chatService.getMessages(
        widget.roomId,
      );

      setState(() {
        messages = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Error load messages: $e',
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  void listenRealtime() {
    channel =
        chatService.subscribeMessages(
      roomId: widget.roomId,
      onNewMessage: (newMessage) {
        setState(() {
          messages.add(newMessage);
        });
      },
    );
  }

  Future<void> sendMessage() async {
    final text =
        messageController.text.trim();

    if (text.isEmpty) return;

    await chatService.sendMessage(
      roomId: widget.roomId,
      senderRole: widget.senderRole,
      senderId: widget.senderId,
      message: text,
    );

    messageController.clear();
  }

  @override
  void dispose() {
    messageController.dispose();

    super.dispose();
  }

  Widget buildMessageBubble(
      Map<String, dynamic> message) {
    final isMe =
        message['sender_id']
                .toString() ==
            widget.senderId;

    return Align(
      alignment: isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin:
            const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        padding:
            const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.blue
              : Colors.grey.shade300,
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: Text(
          message['message'] ?? '',
          style: TextStyle(
            color: isMe
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.namaPembimbing,
            ),
            Text(
              widget.namaSantri,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount:
                        messages.length,
                    itemBuilder:
                        (context, index) {
                      return buildMessageBubble(
                        messages[index],
                      );
                    },
                  ),
          ),

          const Divider(height: 1),

          Padding(
            padding:
                const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        messageController,
                    decoration:
                        const InputDecoration(
                      hintText:
                          'Ketik pesan...',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed:
                      sendMessage,
                  icon: const Icon(
                    Icons.send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}