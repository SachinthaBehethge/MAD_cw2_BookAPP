import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book_reader/model/user_model.dart';
import 'package:flutter_book_reader/screens/home_screen.dart';
import 'package:flutter_book_reader/screens/login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController confirmPasswordController =
      new TextEditingController();
  /*final TextEditingController userTypeController = new TextEditingController();*/

  //firebase
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final firstNameField = TextFormField(
      autofocus: false,
      controller: firstNameController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regExp = new RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("First name cannot be empty");
        }
        if (!regExp.hasMatch(value)) {
          return ("Enter valid name(minimum 3 characters)");
        }

        return null;
      },
      onSaved: (value) {
        firstNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.account_box),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "First Name",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final lastNameField = TextFormField(
      autofocus: false,
      controller: lastNameController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Last name cannot be empty");
        }

        return null;
      },
      onSaved: (value) {
        lastNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.account_box),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Last Name",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }

        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9+.-]+.[a-z]")
            .hasMatch(value)) {
          return ("Please Enter a Valid Email ");
        }
        return null;
      },
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      validator: (value) {
        RegExp regExp = new RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Please Enter Your Password");
        }
        if (!regExp.hasMatch(value)) {
          return ("minimum password length 6 characters");
        }

        return null;
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key_sharp),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    /*final userType = TextFormField(
      initialValue: "user",
      onSaved: (initialValue) {
        userTypeController.text = initialValue!;
      },
    );*/

    final confirmPasswordField = TextFormField(
      autofocus: false,
      controller: confirmPasswordController,
      obscureText: true,
      validator: (value) {
        if (confirmPasswordController.text != passwordController.text) {
          return ("Password not matched");
        }

        return null;
      },
      onSaved: (value) {
        confirmPasswordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key_sharp),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Confirm Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final signupButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.orange,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          signUp(emailController.text, passwordController.text);
        },
        child: Text(
          "Sign Up",
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
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(35.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 200,
                        child: Image.asset(
                          "assets/logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      firstNameField,
                      SizedBox(
                        height: 30,
                      ),
                      lastNameField,
                      SizedBox(
                        height: 30,
                      ),
                      emailField,
                      SizedBox(
                        height: 30,
                      ),
                      passwordField,
                      SizedBox(
                        height: 30,
                      ),
                      confirmPasswordField,
                      SizedBox(
                        height: 50,
                      ),
                      signupButton,
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text("Already an User?  "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            },
                            child: Text(
                              "SignIn",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.deepOrangeAccent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                postDetailsToFirebase(),
              })
          .catchError((e) {
        Fluttertoast.showToast(msg: e!.message);
      });
    }
  }

  postDetailsToFirebase() async {
    //caling fire store
    //calling user model
    //sending data
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    //writing values
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.firstName = firstNameController.text;
    userModel.lastName = lastNameController.text;
    userModel.usertype = 'user';

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());

    Fluttertoast.showToast(msg: "SignUp Successfully");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false);
  }
}
