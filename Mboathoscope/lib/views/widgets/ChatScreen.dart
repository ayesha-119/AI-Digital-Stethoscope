import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import '../../models/Doctor.dart';

class ChatScreen extends StatelessWidget {
  final Doctor doctor;

  ChatScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentUserId = generateRandomUserId();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${doctor.name}'),
      ),
      body: ChatMessages(doctor: doctor, currentUserId: currentUserId),
    );
  }
}

class ChatMessages extends StatefulWidget {
  final Doctor doctor;
  final String currentUserId;

  const ChatMessages({Key? key, required this.doctor, required this.currentUserId}) : super(key: key);

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('messages').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final messages = snapshot.data!.docs.reversed;
              List<Widget> messageWidgets = [];

              for (var message in messages) {
                final messageText = message['text'];
                final messageSender = message['sender'];

                final messageWidget = MessageBubble(
                  sender: messageSender,
                  text: messageText,
                  isMe: widget.currentUserId == messageSender,
                );

                messageWidgets.add(messageWidget);
              }

              return ListView(
                reverse: true,
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                children: messageWidgets,
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your message...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  sendMessage(widget.currentUserId);
                  _controller.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void sendMessage(String currentUserId) {
    String messageText = _controller.text.trim();
    if (messageText.isNotEmpty) {
      FirebaseFirestore.instance.collection('messages').add({
        'text': messageText,
        'sender': currentUserId,
        'recipient': widget.doctor.id,
        'timestamp': Timestamp.now(),
      });
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  MessageBubble({required this.sender, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
          Material(
            elevation: 5.0,
            borderRadius: isMe
                ? BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            )
                : BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String generateRandomUserId() {
  var random = Random();
  return random.nextInt(999999).toString().padLeft(6, '0');
}
