import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aritmatika/pages/HelpPage.dart';
import 'package:aritmatika/pages/ClassicSettingPage.dart';
import 'package:aritmatika/pages/BitwiseSettingPage.dart';
import 'package:aritmatika/pages/RandomSettingPage.dart';
import 'package:aritmatika/pages/SolverPage.dart';
import 'package:aritmatika/pages/TimedHomePage.dart';
import 'package:aritmatika/pages/ProfilePage.dart';
import 'package:aritmatika/pages/LeaderboardPage.dart';

import '../components/drawer.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _time = '';
  bool _loading = true;

  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
  }

  Future<void> signout() async {
    User? a = FirebaseAuth.instance.currentUser!;
    if(a == null) {
      print("User null");
    } else{
      print(a.uid);
    }
    await FirebaseAuth.instance.signOut();
    print("yey");
  }

  // set up drawer

  void goToProfilePage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(),
        ));
  }

  void goToLeaderboardPage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LeaderboardPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help),
            iconSize: 40,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
            },
          ),
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signout,
        onLeaderboardTap: goToLeaderboardPage,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Image.asset(
          //   'assets/bg-home.gif',
          //   fit: BoxFit.cover,
          // ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    'Welcome ' + user.email!,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TimedHomePage()),
                    );
                  },
                  child: Text(
                    'Timed',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClassicSettingPage()),
                    );
                  },
                  child: Text(
                    'Classic',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BitwiseSettingPage()),
                    );
                  },
                  child: Text(
                    'Bitwise',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RandomSettingPage()),
                    );
                  },
                  child: Text(
                    'Random',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SolverPage()),
                    );
                  },
                  child: Text(
                    'Solver',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    signout();
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
