import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_hub/model/chat_user_model.dart';
import 'package:talk_hub/model/message_model.dart';

class APIs {

  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User get user => firebaseAuth.currentUser!;

  static late ChatUserModel me;

  static Future<bool> userExists() async {
    return (await firestore.collection('user').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('user').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUserModel.fromJson(user.data()!);
        log('my data :${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUserModel(
      image: user.photoURL.toString(),
      name: user.displayName.toString(),
      about: 'hey there i am using talk hub !!',
      createdAt: time,
      lastActive: time,
      id: user.uid,
      isOnline: false,
      pushToken: '',
      email: user.email.toString(),
    );
    return await firestore
        .collection('user')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllusers() {
    return firestore
        .collection('user')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore
        .collection('user')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('extension : $ext');

    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');

    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data transferred: ${p0.bytesTransferred / 1000} kb');
    });

    me.image = await ref.getDownloadURL();
    await firestore
        .collection('user')
        .doc(user.uid)
        .update({'image': me.image});
  }

  //     Chat Api sections    ///

  static String getConversationID(String id) {
    return user.uid.hashCode <= id.hashCode
        ? '${user.uid}_$id'
        : '${id}_${user.uid}';
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUserModel user) {
    return firestore
        .collection('chat/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUserModel chatUser, String msg, Type type) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final MessageModel message = MessageModel(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        sent: time,
        fromId: user.uid);

    final ref = firestore
        .collection('chat/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(MessageModel message) async {
    firestore
        .collection('chat/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUserModel user) {
    return firestore
        .collection('chat/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static sendChatImage(ChatUserModel chatUser, File file) async {
    final ext = file.path.split('.').last;

    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data transferred: ${p0.bytesTransferred / 1000} kb');
    });

    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //-------  Upload Status ------//

  static Future<void> storeStatus({
  required String userName,
  required String userPhoto, 
  required String userId,
  required String text,
  required List<XFile> images, // Change to List<XFile>
}) async {
  List<String> imageUrls = [];

  // Upload each image to Firebase Storage
  for (XFile image in images) {
    final storageRef = FirebaseStorage.instance.ref().child('statuses/$userId/${DateTime.now().microsecondsSinceEpoch}');
    await storageRef.putFile(File(image.path));

    // Get download URL of uploaded image
    final imageUrl = await storageRef.getDownloadURL();
    imageUrls.add(imageUrl);
  }

  // Create status document in Firestore with multiple image URLs
  final docRef = FirebaseFirestore.instance.collection('statuses').doc(userId);
  await docRef.set({
    'userName': userName,
    'userPhoto': userPhoto,
    'text': text,
    'imageUrls': imageUrls, // Store multiple image URLs
    'timestamp': DateTime.now(),
  });
}

 static Future<DocumentSnapshot<Map<String, dynamic>>> getMyStatus() async {
  final docRef = FirebaseFirestore.instance.collection('statuses').doc(FirebaseAuth.instance.currentUser!.uid);
  final snapshot = await docRef.get();
  return snapshot;
}


static Future<List<DocumentSnapshot<Map<String, dynamic>>>> getOtherStatuses() async {
  final query = FirebaseFirestore.instance.collection('statuses').orderBy('timestamp', descending: true);
  final snapshot = await query.get();
  return snapshot.docs;
}

  static Future<String> uploadVideo(String videoUrl) async {
    Reference ref = storage.ref().child('videos/${DateTime.now()}.mp4');
    await ref.putFile(File(videoUrl));
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }
}
