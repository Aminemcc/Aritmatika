import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:aritmatika/pages/home_page.dart';
import 'package:aritmatika/pages/LoginPage.dart';

import 'LoginOrRegisterPage.dart';
import 'package:aritmatika/pages/HomePage.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            return HomePage();
          }

          // user is not logged in
          else {
            return LoginOrRegisterPage(key: UniqueKey()); // Or any other key generation method

          }
        },
      ),
    );
  }
}