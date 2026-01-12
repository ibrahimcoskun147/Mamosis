import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage service for uploading mammogram images
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload mammogram image and return download URL
  Future<String> uploadMammogramImage(File imageFile) async {
    try {
      final fileName = 'mammograms/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete mammogram image by URL
  Future<void> deleteMammogramImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore deletion errors
    }
  }
}
