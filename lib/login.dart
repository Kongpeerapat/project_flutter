import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user/Admin_stadium/admin_login.dart';
import 'package:user/forgotpass.dart';
import 'webbord.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Webbord(userId: userCredential.user!.uid),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'user-not-found') {
        message = ' Email ไม่ถูกต้อง';
      } else if (e.code == 'wrong-password') {
        message = 'Password ไม่ถูกต้อง';
      } else {
        message = 'กรุณากรอก Email Password ให้ถูกต้อง';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 0),
                child: Icon(
                  Icons.person_pin,
                  size: 180,
                  color: Color.fromARGB(255, 31, 24, 24),
                ),
              ),
              const Text(
                "Login",
                style: TextStyle(fontSize: 30),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 50,
                  right: 50,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromARGB(255, 219, 212, 212),
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Icon(
                          Icons.email,
                          color: Color.fromARGB(255, 143, 143, 143),
                        ),
                      ),
                      hintText: 'Email',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50, top: 30, right: 50),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromARGB(255, 219, 212, 212),
                  ),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Icon(Icons.password),
                      ),
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.black),
                    ),
                    obscureText: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50, top: 50, right: 50),
                child: Container(
                  width: 400,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.black),
                  child: TextButton(
                    onPressed: _login,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Register(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.perm_contact_cal_sharp,
                          size: 20,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Register",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () { Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Forgotpass(),
                    ),
                  );},
                    child: const Text(
                      "Forgotpassword ?",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Admin stdium login",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,color: Colors.amber),
                    ),
                    Icon(Icons.stadium_rounded,color: Colors.amber,)
                  ],
                ),
                
              ),
            ],
          ),
        ),
      ),
    );
  }
}
