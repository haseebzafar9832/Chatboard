import 'package:chaaatboardd/chaat/HomeScreen.dart';
import 'package:chaaatboardd/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  GoogleSignIn googleSignIn = GoogleSignIn();

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future SinginFucntion() async {
    GoogleSignInAccount? googleuser = await googleSignIn.signIn();
    if (googleuser == null) {
      return;
    }
    final googleauth = await googleuser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleauth.accessToken,
      idToken: googleauth.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    DocumentSnapshot userExist = await FirebaseFirestore.instance
        .collection('AllUsers')
        .doc(userCredential.user!.uid)
        .get();
    if (userExist.exists) {
      print("User Already Exists in Database");
    } else {
      await firebaseFirestore
          .collection('AllUsers')
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'name': userCredential.user!.displayName,
        'image': userCredential.user!.photoURL,
        'date': DateTime.now(),
        'uid': userCredential.user!.uid,
      });

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => MyApp()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        "https://cdn.iconscout.com/icon/free/png-256/chat-2639493-2187526.png"),
                  ),
                ),
              ),
            ),
            Text(
              "Chat App",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: ElevatedButton(
                onPressed: () async {
                  await SinginFucntion();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("done"),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/1024px-Google_%22G%22_Logo.svg.png",
                      height: 26,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Sign in with Google",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
