import 'package:aritmatika/services/UserService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/services/LeaderboardService.dart';
import '/services/UserService.dart';
import '/pages/ProfilePageDetail.dart';
import '/pages/TimedHistoryPage.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final String mode = ""; 
  final LeaderboardService leaderboardService = LeaderboardService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        // leading:
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.menu),
        // ),
        title: const Text("L E A D E R B O A R D"),
        actions: [ 
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.emoji_events_outlined)
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: leaderboardService.getHistoryStream('timer_20_29'),
        builder: (context, snapshot){
          //if data exist get all docs
          if(snapshot.hasData){
            List leaderboardList = snapshot.data!.docs;

            //display as list
            return ListView.separated(
              shrinkWrap: false,
              separatorBuilder: 
                (context, index) => const Divider(
                  thickness: 1,
                  color: Colors.blueAccent,
                  indent: 10,
                  endIndent: 10,
                ),
              itemCount: leaderboardList.length,
              itemBuilder: (context, index) {
                //get each doc
                DocumentSnapshot document = leaderboardList[index];
                String docId = document.id;

                //get note from each doc
                Map<String, dynamic> data = 
                  document.data() as Map<String, dynamic>;
                String username = data['username'];
                String time = data['displayTime'];
                
                //TODO change mode = change leaderboard?

                return GestureDetector(
                  onTap: () async {
                    var temp = await UserService.getUserData(username); 
                    // Handle the tap event
                    print('Tapped on item ${temp?.id}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(temp?.id),
                      ));
                  },
                  child: ListTile(
                    leading: Text(
                      "#${index+1}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),                    
                    ),

                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent[300],
                          child: Text(username[0].toUpperCase()), //foto profil placeholder?
                        ),
                        const SizedBox(width: 5),
                        Text(username),
                      ],
                    ),
                    
                    subtitle: Text("Best Record: $time"),
                    // Add the trailing button
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () async {
                        var temp = await UserService.getUserData(username);
                        print('aaaaaa');
                        // Handle the button press event
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimedHistoryPage(mode: 'timer20-29', docId: docId),
                          ));
                      },
                    ),
                    //TODO highlight user when top 100

                    //TODO show user even if not top 100
                  ),
                );
              }
            );
          }

          else {
            return const Text("no data found");
          }
        }
      )
    );
  }
}
