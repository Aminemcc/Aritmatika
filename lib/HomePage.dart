import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HelpPage.dart';
import 'ClassicSettingPage.dart';
import 'BitwiseSettingPage.dart';
import 'RandomSettingPage.dart';
import 'SolverPage.dart';

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
                    FirebaseAuth.instance.signOut();
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
