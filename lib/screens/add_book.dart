import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_book_reader/api/firebase_api.dart';
import 'package:flutter_book_reader/screens/admin_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';

class AddBook extends StatefulWidget {
  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final TextEditingController bookNameController = new TextEditingController();
  final TextEditingController bookDescController = new TextEditingController();

  UploadTask? task;
  File? file;

  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file!.path) : 'No File Selected';

    final addPdf = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(0),
      color: Colors.lightBlue,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          selectFile();
        },
        child: Text(
          "Select Pdf",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    final bookNameField = TextFormField(
      autofocus: false,
      controller: bookNameController,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Book Name");
        }
        return null;
      },
      onSaved: (value) {
        bookNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.menu_book),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Book Name",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
      ),
    );

    final bookDescField = TextFormField(
      autofocus: false,
      controller: bookDescController,
      keyboardType: TextInputType.text,
      //validator: (){},
      onSaved: (value) {
        bookNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.app_registration_outlined),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Book Description/Auther",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
      ),
    );

    final addBookButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.orange,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          uploadFile(context);
        },
        child: Text(
          "Add Book",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminScreen()));
            },
            icon: Icon(Icons.arrow_back)),
        title: Text("Add New Book"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book,
                color: Colors.lightBlue,
                size: 80,
              ),
              SizedBox(height: 10),
              bookNameField,
              SizedBox(height: 15),
              bookDescField,
              SizedBox(height: 15),
              addPdf,
              SizedBox(height: 8),
              Text(
                fileName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 48),
              addBookButton,
              SizedBox(height: 20),
              task != null ? buildUploadStatus(task!) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file = File(path));
  }

  Future uploadFile(BuildContext context) async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    await firebaseFirestore.collection("Books").doc().set({
      'url': urlDownload,
      'title': bookNameController.text,
      'description': bookDescController.text,
    });

    Fluttertoast.showToast(msg: "Book Added Successfully");
    Navigator.of(context).pop();
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              '$percentage %',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            );
          } else {
            return Container();
          }
        },
      );
}
