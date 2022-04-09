import 'package:chaaatboardd/chaat/auth_screen.dart';
import 'package:chaaatboardd/chaat/chatscreen.dart';
import 'package:chaaatboardd/chaat/model/user_model.dart';
import 'package:chaaatboardd/chaat/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  UserModel user;
  HomeScreen({
    required this.user,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Room"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () async {
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => AuthScreen()),
                  (route) => false);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => SearchScreeen(user: widget.user)));
        },
        child: Icon(Icons.search),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("AllUsers")
            .doc(widget.user.uid)
            .collection("messages")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.length < 1) {
              return Center(
                child: Text("No Chats Available !"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var friendId = snapshot.data!.docs[index].id;
                var lastMsg = snapshot.data!.docs[index]['last_message'];
                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("AllUsers")
                      .doc(friendId)
                      .get(),
                  builder: (BuildContext context, AsyncSnapshot asyncsnapshot) {
                    if (asyncsnapshot.hasData) {
                      var friend = asyncsnapshot.data;
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(friend['image']),
                        ),
                        title: Text(friend['name']),
                        subtitle: Container(
                          child: Text(
                            "$lastMsg",
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                        Friedname: friend['name'],
                                        FriendImage: friend['image'],
                                        currentuser: widget.user,
                                        friendId: friend['uid'],
                                      )));
                        },
                      );
                    }
                    return LinearProgressIndicator();
                  },
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
