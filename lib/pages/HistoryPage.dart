import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:aritmatika/services/HistoryService.dart';
import 'package:aritmatika/pages/SolverPage.dart';

class HistoryPage extends StatefulWidget {
  final String mode;

  HistoryPage({required this.mode});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService historyService = HistoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History (${widget.mode})'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed:() {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Delete All History?"),
                  content: Text("Apakah Anda yakin ingin menghapus seluruh history?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel")
                    ),
                    TextButton(
                      onPressed: () {
                        historyService.deleteAllHistoryEntries(widget.mode);
                        Navigator.pop(context);
                      },
                      child: Text("Delete"),
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      ),
                    )
                  ]
                )
              );
            }
          )
        ]
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: historyService.getHistoryStream(widget.mode),
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

              List<dynamic> numbers = data['numbers'];
              double target = data['target'];
              List<dynamic> operators = data['operators'];
              bool isSolved = data['isSolved'];
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
                                'Target: ${target.toInt()}',
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
                            'Numbers: ${numbers.map((e) => e.toInt()).join(", ")}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Operators: ${operators.join(", ")}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Solved: ${isSolved ? "Yes" : "No"}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isSolved ? Colors.green : Colors.red,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Timestamp: $formattedDate',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => historyService.deleteHistoryEntry(widget.mode, doc.id),
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
