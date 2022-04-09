import 'package:chaaatboardd/chaat/model/user_model.dart';
import 'package:chaaatboardd/chaat/widget/SignleMessage.dart';
import 'package:chaaatboardd/chaat/widget/message_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  UserModel currentuser;
  String friendId;
  String Friedname;
  String FriendImage;
  ChatScreen({
    required this.Friedname,
    required this.FriendImage,
    required this.currentuser,
    required this.friendId,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: Image.network(
                FriendImage,
                height: 40,
              ),
            ),
            SizedBox(width: 10),
            Text(
              Friedname,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("AllUsers")
                    .doc(currentuser.uid)
                    .collection('messages')
                    .doc(friendId)
                    .collection('chats')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.length < 1) {
                      return Center(
                        child: Text("Say Hi"),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      reverse: true,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        bool isMe = snapshot.data!.docs[index]['senderId'] ==
                            currentuser.uid;
                        return SingleMessage(
                            message: snapshot.data!.docs[index]['message'],
                            isMe: isMe);
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          MessageText(currentId: currentuser.uid, friendId: friendId),
        ],
      ),
    );
  }
}
