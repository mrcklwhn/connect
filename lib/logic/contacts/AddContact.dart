import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/screens/data/Models.dart';

class AddContact{
  static Future<String> getLastOnline(ContactUser user) async {
    final databaseReference = await FirebaseFirestore.instance
        .collection(user.id)
        .doc("Information")
        .get();
    return databaseReference.get("lastOnline");
  }

  static Future<String> getDescription(ContactUser user) async {
    final databaseReference = await FirebaseFirestore.instance
        .collection(user.id)
        .doc("Information")
        .get();
    return databaseReference.get("description");
  }

  static Future<String> getImageUrl(ContactUser user) async {
    final databaseReference = await FirebaseFirestore.instance
        .collection(user.id)
        .doc("Information")
        .get();
    return databaseReference.get("imageUrl");
  }
}