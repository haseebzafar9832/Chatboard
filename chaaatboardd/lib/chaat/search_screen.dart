import 'package:chaaatboardd/chaat/chatscreen.dart';
import 'package:chaaatboardd/chaat/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreeen extends StatefulWidget {
  UserModel user;
  SearchScreeen({required this.user});
  @override
  State<SearchScreeen> createState() => _SearchScreeenState();
}

class _SearchScreeenState extends State<SearchScreeen> {
  TextEditingController searchC = TextEditingController();
  List<Map> searchResult = [];
  List data = [];

  bool isLoading = false;
  void onsearch() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance.collection('AllUsers').get().then((value) {
      print("chek${value.docs.length}");
      if (value.docs.length > 0) {
        value.docs.forEach((user) {
          if (user.data()['email'] != widget.user.email) {
            searchResult.add(user.data());
          }
        });
        setState(() {
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("No User Found")));
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Your Friend"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    keyboardType: TextInputType.name,
                    controller: searchC,
                    decoration: InputDecoration(
                      hintText: "type username....",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  onsearch();
                  data = searchResult
                      .where((element) => element.containsValue(searchC.text))
                      .toList();
                },
                icon: Icon(Icons.search),
              )
            ],
          ),
          if (searchResult.length > 0)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResult.length,
                itemBuilder: (BuildContext context, int index) {
                  print("ali");
                  return ListTile(
                    leading: CircleAvatar(
                      child: Image.network(searchResult[index]['image']),
                    ),
                    title: Text(searchResult[index]['name']),
                    subtitle: Text(searchResult[index]['email']),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          searchC.text = "";
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              Friedname: searchResult[index]['name'],
                              FriendImage: searchResult[index]['image'],
                              currentuser: widget.user,
                              friendId: searchResult[index]['uid'],
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.message),
                    ),
                  );
                },
              ),
            )
          else if (isLoading == true)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
