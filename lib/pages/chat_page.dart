import 'package:counter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:counter/widgets/message_bubble_widget.dart';
import 'package:counter/widgets/loading_widget.dart';
class ChatScreen extends StatelessWidget {
  const ChatScreen(this.chatContext, this.loungeCallback, {super.key});
  final dynamic chatContext;
  final Function loungeCallback;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: 
          ChatScreenBody(chatContext, loungeCallback),
    );
  }
}

class ChatScreenBody extends StatefulWidget {
  const ChatScreenBody(this.chatContext, this.loungeCallback, {super.key});
  final dynamic chatContext;
  final Function loungeCallback;
  @override
  _ChatScreenState createState() => _ChatScreenState(chatContext, loungeCallback);
}

class _ChatScreenState extends State<ChatScreenBody> {
  _ChatScreenState(this.chatContext, this.loungeCallback);
  late String userId;
  late String currentUserId;
  late String chatRoomId;
  final dynamic chatContext;
  final Function loungeCallback;
  final TextEditingController _messageController = TextEditingController();
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    userId = chatContext['user_id'];
    if( userId != currentUserId) throw Exception('Invalid user id');
    getChatRoom(chatContext);
  }
  Future<void> getChatRoom(chatContext) async {
    var query = FirebaseFirestore.instance.collection('chats').doc(chatContext['channel']).collection('messages');
    var querySnapshot = await query.get();
    setState(() {
      isLoading = false;
      chatRoomId = chatContext['channel'];
    });
    print("chatRoomId: $chatRoomId");
  }
  Future<void> sendMessage(String currentUserId, String message) async {
  await FirebaseFirestore.instance.collection('chats').doc(chatContext['channel'])
      .collection('messages').add({
    'message': message,
    'timestamp': FieldValue.serverTimestamp(),
    'sender': currentUserId, // or another identifier for the sender
    });
  }
  Stream<QuerySnapshot> messageStream(String chatRoomId) {
    return FirebaseFirestore.instance.collection('chats').doc(chatContext['channel'])
        .collection('messages').orderBy('timestamp', descending: false)
        .snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Expanded(
            child: !isLoading ? StreamBuilder(
              stream: messageStream(chatRoomId),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const LoadingWidget();
                }
                var messages = snapshot.data!.docs ?? [];
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index].data() as Map<String, dynamic>;
                    bool isMe = message['sender'] == userId;
                      if (message['text'] == null || message['timestamp'] == null) {
                      return const SizedBox.shrink(); // Skip rendering this message
                    }
                    return MessageBubble(
                      text: message['text'],
                      timestamp: message['timestamp'],
                      isMe: isMe,
                    );
                  },
                );
              },
            ) : const LoadingWidget(),
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.only(top:8.0, bottom:8.0, left:12.0, right:12.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Colors.white,
            ),
            child:TextField(
              controller: _messageController,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Type a message',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: AppColorTemplate.lightBlue,),
                  onPressed: () {
                    if (_messageController.text.isEmpty) return;
                    if (isLoading) return;
                    sendMessage(currentUserId, _messageController.text);
                    _messageController.clear();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 72),
        ],
      );
  }
}
