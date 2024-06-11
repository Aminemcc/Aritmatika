import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:aritmatika/utils/Generator.dart';
import 'package:aritmatika/utils/SolverUtility.dart';
import 'package:aritmatika/services/HistoryService.dart';
import 'package:aritmatika/services/UserService.dart';
import 'package:aritmatika/services/LeaderboardService.dart';
import 'package:aritmatika/pages/historyPage.dart';


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
  int ?bestTimeTaken = 0;
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
    if(bestTimeTaken != null && bestTimeTaken != -1){
      bestDisplayTime = StopWatchTimer.getDisplayTime(bestTimeTaken!, milliSecond: true);
    } else{
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

  fetchGameData() {
    for(int i = 0; i < round; i++){
      isSolved = false;
      numbers.clear();
      undoNumbers.clear();
      selectedIndexes.clear();
      gameData = generator.generate(n, 1, 13, targetMin, targetMax, operators, false);
      gameDatas.add(gameData);
    }
  }

  void newNumbers(int i){
    // i = current round (start from 1)
    numbers.clear();
    undoNumbers.clear();
    selectedIndexes.clear();
    startNumbers = gameDatas[i-1]['numbers'];
    target = gameDatas[i-1]['target'].toDouble();
    numbers.addAll(startNumbers.map<double>((e) => e.toDouble()).toList());
    isSelected = List.generate(numbers.length, (index) => false);
    undoNumbers.add(List.from(numbers));
    historyData = {
      "round": current_round,
      "numbers": startNumbers,
      "target": target,
      "operators": operators,
      "isSolved": isSolved,
      "timeTaken" : -1,
      "displayTime" : "null",
      "timestamp" : FieldValue.serverTimestamp()
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

  void undo(){
    if(undoNumbers.length <= 1){
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
      if (selectedIndexes.length == 0) {
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
        if(result == util.infinity || result == util.infinityDouble){
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
      if(result == target && numbers.length == 1){
        await updateHistoryDatas(current_round);
        ++current_round;
        if(current_round > round){
          await endGame();
        } else{
          newNumbers(current_round);
        }
        // isSolved = true;
        // historyData["isSolved"] = true;
        // updateSolvedStatus();
      }
      setState(() {}); // Update the UI after all state changes
    } catch (e) {
      return;
    }
  }


  Future<void> updateHistoryDatas(int i) async {
    int val = await _stopWatchTimer.rawTime.first;
    historyDatas[i-1]['round'] = current_round;
    historyDatas[i-1]["isSolved"] = true;
    historyDatas[i-1]["timeTaken"] = val - previous_time;
    previous_time = val;
    historyDatas[i-1]["displayTime"] = StopWatchTimer.getDisplayTime(historyDatas[i-1]["timeTaken"], milliSecond: true);
  }

  Future<void> endGame() async {
    _currentState = TimerState.end;
    if (_stopWatchTimer.isRunning) {
      _stopWatchTimer.onStopTimer();
      timeTaken = await _stopWatchTimer.rawTime.first;
    }
    bool isCleared = current_round == round + 1;
    Map<String, dynamic> to_upload = {
      // "datas" : historyDatas,
      "isCleared" : isCleared,
      "clearedRound" : current_round - 1,
      "timeTaken" : timeTaken,
      "displayTime" : StopWatchTimer.getDisplayTime(timeTaken, milliSecond: true)
    };
    Map<String, dynamic> to_upload_leaderboard = {
      "datas" : historyDatas,
      "timeTaken" : val,
      "displayTime" : StopWatchTimer.getDisplayTime(val, milliSecond: true),
      "username": username
    };
    await historyService.addHistoryEntry("timer20-29", to_upload);
    if(current_round == round + 1){
      //check for best time
      int ?bestTime = await userService.getBestTimeTaken();
      if(bestTime == null || bestTime == -1){
        await userService.updateBestTime(to_upload["timeTaken"], to_upload["displayTime"]);
      } else if(bestTime > to_upload["timeTaken"]){
        await userService.updateBestTime(to_upload["timeTaken"], to_upload["displayTime"]);
      }
      await leaderboardService.insertToLeaderboard("timer20-29", to_upload_leaderboard);
    }
  }

  Widget buildTarget() {
    return Column(
      children: [
        Text(
          'Target',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        Text(
          '$target',
          style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildNumbers() {
    return Column(
      children: [
        Text(
          'Numbers',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        Wrap(
          children: numbers
              .asMap()
              .entries
              .map((entry) => GestureDetector(
            onTap: () => handleNumber(entry.key),
            child: Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isSelected[entry.key] ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                entry.value.toString(),
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget buildOperators() {
    return Column(
      children: [
        Text(
          'Operators',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        Wrap(
          children: operators
              .map((operator) => GestureDetector(
            onTap: () => applyOperator(operator),
            child: Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                operator,
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget buildTimer() {
    return Column(
      children: [
        Text(
          'Timer',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        StreamBuilder<int>(
          stream: _stopWatchTimer.rawTime,
          initialData: 0,
          builder: (context, snapshot) {
            final value = snapshot.data!;
            final displayTime =
            StopWatchTimer.getDisplayTime(value, milliSecond: true);
            return Text(
              displayTime,
              style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red),
            );
          },
        ),
      ],
    );
  }

  Widget buildBestTime() {
    return Column(
      children: [
        Text(
          'Best Time',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        Text(
          bestDisplayTime,
          style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ],
    );
  }

  Widget buildTimerButton() {
    String buttonText = '';
    VoidCallback? onPressed;

    switch (_currentState) {
      case TimerState.start:
        buttonText = 'Start';
        onPressed = _startTimer;
        break;
      case TimerState.play:
        buttonText = 'Stop';
        onPressed = _stopAndShowTime;
        break;
      case TimerState.end:
        buttonText = 'Reset';
        onPressed = reset;
        break;
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: Text(buttonText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timed Mode'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          _handleBackPressed();
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTarget(),
              SizedBox(height: 20.0),
              buildNumbers(),
              SizedBox(height: 20.0),
              buildOperators(),
              SizedBox(height: 20.0),
              buildTimer(),
              SizedBox(height: 20.0),
              buildBestTime(),
              SizedBox(height: 20.0),
              buildTimerButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    _stopWatchTimer.dispose();
  }
}

