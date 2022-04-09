import 'package:chaaatboardd/chaat/HomeScreen.dart';
import 'package:chaaatboardd/chaat/auth_screen.dart';
import 'package:chaaatboardd/chaat/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn = false;
  // @override
  // void initState() {
  //   getLoggedInState();
  //   super.initState();
  // }

  // getLoggedInState() async {
  //   HelperFunctions.getingUserLoggedIdSharedpreference().then((value) {
  //     setState(() {
  //       userIsLoggedIn = value!;
  //     });
  //   });
  // }
  Future<Widget> userSignedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(user.uid)
          .get();
      UserModel usermodel = UserModel.formjson(userData);

      return HomeScreen(
        user: usermodel,
      );
    } else {
      return AuthScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
            future: userSignedIn(),
            builder: (context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              }
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            })

        // userIsLoggedIn == null ? ChatRoom() : Auhtenticate(),
        );
  }
}
