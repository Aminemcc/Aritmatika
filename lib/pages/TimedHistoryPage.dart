import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:aritmatika/services/HistoryService.dart';
import 'package:aritmatika/pages/SolverPage.dart';

class TimedHistoryPage extends StatefulWidget {
  final String mode;
  final String docId;
  TimedHistoryPage({required this.mode, required this.docId});

  @override
  _TimedHistoryPageState createState() => _TimedHistoryPageState();
}

class _TimedHistoryPageState extends State<TimedHistoryPage> {
  final HistoryService historyService = HistoryService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Timed History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: historyService.getSubHistoryStream(widget.mode, widget.docId, "datas"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No history data found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              int round = data['round'];
              List<dynamic> numbers = data['numbers'];
              double target = data['target'];
              List<dynamic> operators = data['operators'];
              bool isSolved = data['isSolved'];
              String displayTime = data['displayTime'];
              Timestamp timestamp = data['timestamp'];
              String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SolverPage(
                        target: target.toDouble(),
                        numbers: List<int>.from(numbers.map((e) => e.toInt())),
                        operators: List<String>.from(operators),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: isSolved ? Colors.green[50] : Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Round ${round}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                isSolved ? Icons.check_circle : Icons.cancel,
                                color: isSolved ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Target : ${target.toInt()}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${numbers.map((e) => e.toInt()).join(", ")}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${operators.join(", ")}',
                            style: TextStyle(fontSize: 16),
                          ),
                          // SizedBox(height: 8),
                          // Text(
                          //   'Solved: ${isSolved ? "Yes" : "No"}',
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     color: isSolved ? Colors.green : Colors.red,
                          //   ),
                          // ),
                          SizedBox(height: 8),
                          Text(
                            '$displayTime',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$formattedDate',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
