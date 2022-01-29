import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book_reader/model/user_model.dart';
import 'package:flutter_book_reader/screens/admin_screen.dart';
import 'package:flutter_book_reader/screens/login_screen.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //user details
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("Read Books");

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
    CircularProgressIndicator;
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
              checkRole();
            },
            icon: Icon(Icons.menu_book_sharp)),
        backgroundColor: Colors.deepOrangeAccent,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                if (this.customIcon.icon == Icons.search) {
                  this.customIcon = Icon(Icons.cancel);
                  this.customSearchBar = TextField(
                    textInputAction: TextInputAction.go,
                    onSubmitted: (value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen(
                                    searchText: value,
                                  )));
                    },
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                      hintText: "Search",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } else {
                  this.customIcon = Icon(Icons.search);
                  this.customSearchBar = Text("Read Books");
                }
              });
            },
            icon: customIcon,
          ),
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
        title: customSearchBar,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Books').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, i) {
                  QueryDocumentSnapshot x = snapshot.data!.docs[i];

                  return ListTile(
                    leading: Icon(
                      Icons.menu_book,
                      color: Colors.red,
                      size: 25,
                    ),
                    title: Text(x['title']),
                    subtitle: Text(x['description']),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => View(
                                    url: x['url'],
                                  )));
                    },
                  );
                });
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  checkRole() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    User? user = FirebaseAuth.instance.currentUser;
    final DocumentSnapshot snap =
        await firebaseFirestore.collection('users').doc(user!.uid).get();

    final userType = snap['userType'];

    if (userType == 'admin') {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminScreen()));
    }
  }
}

class View extends StatelessWidget {
  PdfViewerController? _pdfViewerController;
  final url;

  View({this.url});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
        title: Text('Book'),
      ),
      body: SfPdfViewer.network(
        url,
        controller: _pdfViewerController,
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  final searchText;
  SearchScreen({this.searchText});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
        title: Text("Search Results"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Books')
            .where('title', isGreaterThanOrEqualTo: searchText)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, i) {
                  QueryDocumentSnapshot x = snapshot.data!.docs[i];

                  return ListTile(
                    leading: Icon(
                      Icons.menu_book,
                      color: Colors.red,
                      size: 25,
                    ),
                    title: Text(x['title']),
                    subtitle: Text(x['description']),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => View(
                                    url: x['url'],
                                  )));
                    },
                  );
                });
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
