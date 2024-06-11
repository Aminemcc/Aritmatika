import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:aritmatika/utils/Generator.dart';
import 'package:aritmatika/utils/SolverUtility.dart';
import 'package:aritmatika/services/HistoryService.dart';
import 'package:aritmatika/services/UserService.dart';
import 'package:aritmatika/services/LeaderboardService.dart';
import 'package:aritmatika/services/SettingService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TimerState { start, play, end }

class TimedHomePage extends StatefulWidget {
  const TimedHomePage();

  @override
  _TimedHomePageState createState() => _TimedHomePageState();
}

class _TimedHomePageState extends State<TimedHomePage> {
  final String mode = "Timed";
  final int n = 4;
  final int targetMin = 20;
  final int targetMax = 29;
  int round = 0;
  final List<String> operators = ["+", "-", "*", "/"];

  final Generator generator = Generator();
  final SolverUtility util = SolverUtility();
  final historyService = HistoryService();
  final userService = UserService();
  final leaderboardService = LeaderboardService();
  String? username = "";

  bool historyUploaded = false;

  int timeTaken = 0;
  int? bestTimeTaken = 0;
  String bestDisplayTime = "";

  Map<String, dynamic> gameData = {};
  List<List<double>> undoNumbers = [];
  int current_round = 1; // max => round
  List<double> numbers = [];
  List<int> startNumbers = [];
  String currentOperator = '';
  double target = 0;
  List<bool> isSelected = [];
  List<int> selectedIndexes = [];
  bool updatedSelection = false;

  List<Map<String, dynamic>> gameDatas = [];
  List<Map<String, dynamic>> historyDatas = [];
  Map<String, dynamic> historyData = {};
  String historyId = '';
  bool isSolved = false;

  int previous_time = 0;
  TimerState _currentState = TimerState.start;
  int _clickCount = 0;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    username = await userService.getUsernameByUid();
    bestTimeTaken = await userService.getBestTimeTaken();
    if (bestTimeTaken != null && bestTimeTaken != -1) {
      bestDisplayTime = StopWatchTimer.getDisplayTime(bestTimeTaken!, milliSecond: true);
    } else {
      bestTimeTaken = -1;
      bestDisplayTime = "??:??:??:??";
    }
    round = await SettingService.getField("timed", "round");
    previous_time = 0;
    current_round = 1;
    _currentState = TimerState.start;
    gameDatas.clear();
    historyDatas.clear();
    fetchGameData();
    newNumbers(1);
    _stopWatchTimer.onResetTimer();

    // historyId = await historyService.addHistoryEntry(mode, historyData);
    setState(() {});
  }

  void fetchGameData() {
    for (int i = 0; i < round; i++) {
      isSolved = false;
      numbers.clear();
      undoNumbers.clear();
      selectedIndexes.clear();
      gameData = generator.generate(n, 1, 13, targetMin, targetMax, operators, false);
      gameDatas.add(gameData);
    }
  }

  void newNumbers(int i) {
    // i = current round (start from 1)
    numbers.clear();
    undoNumbers.clear();
    selectedIndexes.clear();
    startNumbers = List<int>.from(gameDatas[i - 1]['numbers']);
    target = gameDatas[i - 1]['target'].toDouble();
    numbers.addAll(startNumbers.map<double>((e) => e.toDouble()).toList());
    isSelected = List.generate(numbers.length, (index) => false);
    undoNumbers.add(List.from(numbers));
    historyData = {
      "round": current_round,
      "numbers": startNumbers,
      "target": target,
      "operators": operators,
      "isSolved": isSolved,
      "timeTaken": -1,
      "displayTime": "null",
      "timestamp": FieldValue.serverTimestamp()
    };
    historyDatas.add(historyData);
  }

  void _startTimer() {
    setState(() {
      _currentState = TimerState.play;
      _clickCount = 0;
      _stopWatchTimer.onResetTimer();
      _stopWatchTimer.onStartTimer();
    });
  }

  void _stopAndShowTime() {
    setState(() {
      _currentState = TimerState.end;
      _stopWatchTimer.onStopTimer();
    });
  }

  Future<void> _handleBackPressed() async {
    await endGame();

    _stopAndShowTime();
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void reset() {
    numbers.clear();
    undoNumbers.clear();
    selectedIndexes.clear();
    numbers.addAll(startNumbers.map<double>((e) => e.toDouble()).toList());
    isSelected = List.generate(numbers.length, (index) => false);
    undoNumbers.clear();
    undoNumbers.add(List.from(numbers)); // Save initial numbers state
    currentOperator = '';
    setState(() {});
  }

  void undo() {
    if (undoNumbers.length <= 1) {
      return;
    }
    numbers.clear();
    numbers = undoNumbers.removeAt(undoNumbers.length - 2);
    selectedIndexes.clear();
    isSelected = List.generate(numbers.length, (index) => false);
    currentOperator = '';
    setState(() {});
  }

  void handleNumber(int index) {
    setState(() {
      if (selectedIndexes.isEmpty) {
        selectedIndexes.add(index);
        isSelected[index] = !isSelected[index];
      } else {
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
          isSelected[index] = !isSelected[index];
        } else {
          selectedIndexes.add(index);
          isSelected[index] = !isSelected[index];
        }
      }
    });
  }

  Future<void> applyOperator(String operator) async {
    try {
      if (selectedIndexes.length < 2 || !operators.contains(operator)) {
        // Should return something error
        return;
      }
      double result = numbers[selectedIndexes[0]];
      for (int i = 1; i < selectedIndexes.length; i++) {
        result = util.calculateDouble(result, numbers[selectedIndexes[i]], operator);
        if (result == util.infinity || result == util.infinityDouble) {
          throw Exception('Error');
        }
      }
      selectedIndexes.sort((a, b) => b.compareTo(a));
      for (int i = 0; i < selectedIndexes.length; i++) {
        numbers.removeAt(selectedIndexes[i]);
        isSelected.removeAt(selectedIndexes[i]);
      }
      selectedIndexes.clear();
      numbers.add(result); // Add the result
      isSelected.add(false);
      undoNumbers.add(List.from(numbers)); // Save the state after applying the operator
      currentOperator = ''; // Deselect the operator
      if (result == target && numbers.length == 1) {
        await updateHistoryDatas(current_round);
        ++current_round;
        if (current_round > round) {
          await endGame();
        } else {
          newNumbers(current_round);
        }
      }
      setState(() {}); // Update the UI after all state changes
    } catch (e) {
      return;
    }
  }

  Future<void> updateHistoryDatas(int i) async {
    int val = await _stopWatchTimer.rawTime.first;
    historyDatas[i - 1]['round'] = current_round;
    historyDatas[i - 1]["isSolved"] = true;
    historyDatas[i - 1]["timeTaken"] = val - previous_time;
    historyDatas[i - 1]["displayTime"] = StopWatchTimer.getDisplayTime(val - previous_time, milliSecond: true);
    previous_time = val;
    historyData = historyDatas[i - 1];
    historyId = await historyService.addHistoryEntry(mode, historyData);

    // Upload to leaderboard
    if (current_round > round) {
      await leaderboardService.addLeaderboardEntry("timer_20_29", user.uid, {
        "username": username,
        "timeTaken": previous_time,
      });
    }
  }

  Future<void> endGame() async {
    _stopWatchTimer.onStopTimer();
    if (!historyUploaded) {
      historyUploaded = true;
      for (int i = 0; i < historyDatas.length; i++) {
        await historyService.updateHistoryEntry(historyId, mode, historyDatas[i]);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleBackPressed();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Timed Game'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Text(
                  'Round $current_round/$round',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            if (_currentState == TimerState.start)
              ElevatedButton(
                onPressed: _startTimer,
                child: Text('Start'),
              ),
            if (_currentState == TimerState.play)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Target: $target',
                      style: TextStyle(fontSize: 32),
                    ),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 2,
                        ),
                        itemCount: numbers.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => handleNumber(index),
                            child: Container(
                              margin: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: isSelected[index] ? Colors.blue : Colors.grey,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Text(
                                  numbers[index].toString(),
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: operators.map((operator) {
                        return ElevatedButton(
                          onPressed: () => applyOperator(operator),
                          child: Text(operator),
                        );
                      }).toList(),
                    ),
                    ElevatedButton(
                      onPressed: undo,
                      child: Text('Undo'),
                    ),
                    ElevatedButton(
                      onPressed: reset,
                      child: Text('Reset'),
                    ),
                  ],
                ),
              ),
            if (_currentState == TimerState.end)
              Column(
                children: [
                  Text(
                    'Game Over!',
                    style: TextStyle(fontSize: 32),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Back to Menu'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
