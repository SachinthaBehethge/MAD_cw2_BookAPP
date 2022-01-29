import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book_reader/model/user_model.dart';
import 'package:flutter_book_reader/screens/add_book.dart';
import 'package:flutter_book_reader/screens/home_screen.dart';
import 'package:flutter_book_reader/screens/login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    onRefresh(loggedInUser);
  }

  onRefresh(userCredential) {
    setState(() {
      loggedInUser = userCredential;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            icon: Icon(Icons.menu_book_sharp)),
        //Icon(Icons.menu_book_sharp,),
        backgroundColor: Colors.deepOrangeAccent,
        actions: <Widget>[
          TextButton(
              onPressed: () {
                logout(context);
              },
              child: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              )),
        ],
        title: Text("${loggedInUser.firstName}"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Books').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, i) {
                  QueryDocumentSnapshot x = snapshot.data!.docs[i];
                  String id = x['id'];

                  return ListTile(
                      leading: Icon(
                        Icons.menu_book,
                        color: Colors.red,
                        size: 25,
                      ),
                      title: Text(x['title']),
                      subtitle: Text(x['description']),
                      trailing: IconButton(
                          onPressed: () async {
                            try {
                              FirebaseFirestore.instance
                                  .collection('Books')
                                  .doc(id)
                                  .delete()
                                  .then((_) {
                                print("Deleted!");
                              });
                            } catch (e) {
                              print("Cant Delete");
                            }
                          },
                          icon: Icon(Icons.delete)));
                });
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewBook(context);
        },
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  Future<void> addNewBook(BuildContext context) async {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => AddBook()));
  }
}
