import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/constants/strings.dart';
import 'package:chat_app/screens/login.dart';
import 'package:chat_app/services/firebase_service.dart';
import 'package:chat_app/widgets/message_input.dart';
import 'package:chat_app/widgets/message_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseService _firebaseService = FirebaseService();

  String selectedRoom = kDefaultRooms[0]; // Default room

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  Future<void> _sendTextMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await _firebaseService.sendMessage(
        text: text,
        imageUrl: null,
        userEmail: user!.email!,
        userId: user!.uid,
        room: selectedRoom,
      );

      _controller.clear();
      _scrollToTop();
    } catch (error) {
      _showErrorSnackBar('Failed to send message: $error');
    }
  }

  Future<void> _sendImageMessage() async {
    try {
      final imageUrl = await _firebaseService.uploadImageToStorage(ImageSource.gallery);
      if (imageUrl == null) return;

      await _firebaseService.sendMessage(
        text: '',
        imageUrl: imageUrl,
        userEmail: user!.email!,
        userId: user!.uid,
        room: selectedRoom,
      );

      _scrollToTop();
    } catch (error) {
      _showErrorSnackBar('Image upload failed: $error');
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kDarkBlue,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 35),
            const SizedBox(width: 10),
            const Text(kAppTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: selectedRoom,
            underline: const SizedBox(),
            dropdownColor: Colors.blue[100],
            onChanged: (val) => setState(() => selectedRoom = val!),
            items: kDefaultRooms.map((room) => DropdownMenuItem(
              value: room,
              child: Text(" $room"),
            )).toList(),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          MessageInput(
            controller: _controller,
            onSend: _sendTextMessage,
            onImagePick: _sendImageMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('room', isEqualTo: selectedRoom)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final messages = snapshot.data!.docs;

        if (messages.isEmpty) return const Center(child: Text('No messages yet'));

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index].data() as Map<String, dynamic>;
            final isMe = msg['userId'] == user?.uid;

            return MessageItem(msg: msg, isMe: isMe);
          },
        );
      },
    );
  }
}
