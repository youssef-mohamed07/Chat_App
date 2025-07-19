import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // 🔐 Register a new user
  Future<User?> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Registration failed");
    }
  }

  // 🔐 Login existing user
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  // ❌ Logout current user
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // 🔄 Reset password via email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw Exception("Failed to send reset email: $e");
    }
  }

  // 🖼️ Upload image to Firebase Storage and return the URL
  Future<String?> uploadImageToStorage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: source);
      if (pickedImage == null) return null;

      final File file = File(pickedImage.path);
      final ref = _storage
          .ref()
          .child('chat_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(file);
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }

  // 💬 Send a message to Firestore
  Future<void> sendMessage({
    required String text,
    required String? imageUrl,
    required String userEmail,
    required String userId,
    required String room,
  }) async {
    try {
      await _firestore.collection('messages').add({
        'text': text.trim(),
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
        'userEmail': userEmail,
        'userId': userId,
        'room': room,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // 📡 Stream real-time messages by room
  Stream<QuerySnapshot> getMessagesByRoom(String room) {
    return _firestore
        .collection('messages')
        .where('room', isEqualTo: room)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // 📥 Get current user
  User? get currentUser => _auth.currentUser;
}
