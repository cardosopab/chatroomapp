import 'package:chatapp/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:giphy_picker/giphy_picker.dart';

class Database {
  final instance = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  final currentUID = FirebaseAuth.instance.currentUser?.uid;
  final name = FirebaseAuth.instance.currentUser?.displayName;
  var photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
  var email = FirebaseAuth.instance.currentUser?.email;
  GiphyGif? gif;
  late final CollectionReference chatCollectionReference =
      FirebaseFirestore.instance.collection(chatRoom!);
  late final Stream<QuerySnapshot> chatCollectionStream =
      FirebaseFirestore.instance
          .collection(chatRoom!)
          .orderBy(
            'created',
            descending: true,
          )
          .snapshots();

  Stream<List> messages() {
    return FirebaseFirestore.instance.collection(chatRoom!).snapshots().map(
      (snapshot) {
        return snapshot.docs.fold<List>(
          [],
          (previousValue, doc) {
            final data = doc.data();
            data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
            data['id'] = doc.id;
            data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

            return [...previousValue];
          },
        );
      },
    );
  }

  Future addPhoto(url) async {
    try {
      currentUser?.updatePhotoURL(url);
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future addName(nameController) async {
    try {
      currentUser?.updateDisplayName(nameController);
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future addMessage(messageController) async {
    Timestamp created = Timestamp.now();
    try {
      await chatCollectionReference.add({
        'messages': messageController,
        'created': created,
        'user': currentUID,
        'photoUrl': photoUrl,
        'name': name,
        'gif': gif,
      });
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future addGiphy(gif) async {
    Timestamp created = Timestamp.now();
    try {
      await chatCollectionReference.add({
        'messages': '',
        'created': created,
        'user': currentUID,
        'photoUrl': photoUrl,
        'name': name,
        'gif': gif,
      });
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }


}
