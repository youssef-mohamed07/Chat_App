import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageItem extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const MessageItem({super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final timestamp = (msg['createdAt'] as Timestamp).toDate();
    final formattedTime =
    DateFormat('hh:mm a • dd/MM/yyyy').format(timestamp);
    final imageUrl = msg['imageUrl'];
    final hasImage = imageUrl != null && imageUrl.toString().isNotEmpty;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF1976D2) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                msg['userEmail'],
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            if (hasImage)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/logo.png', // 👈 Make sure this file exists
                        height: 180,
                        width: 180,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            if (msg['text'].toString().isNotEmpty)
              Text(
                msg['text'],
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
