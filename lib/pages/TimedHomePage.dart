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
  final int round = 1;
  final List<String> operators = ["+", "-", "*", "/"];

  final Generator generator = Generator();
  final SolverUtility util = SolverUtility();
  final historyService = HistoryService();
  final userService = UserService();
  final leaderboardService = LeaderboardService();
  String? username = "";

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
      "numbers": startNumbers,
      "target": target,
      "operators": operators,
      "isSolved": isSolved,
      "timeTaken" : -1,
      "displayTime" : "null"
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
    print('User pressed back');
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
    historyDatas[i-1]["isSolved"] = true;
    historyDatas[i-1]["timeTaken"] = val - previous_time;
    previous_time = val;
    historyDatas[i-1]["displayTime"] = StopWatchTimer.getDisplayTime(historyDatas[i-1]["timeTaken"], milliSecond: true);
  }

  Future<void> endGame() async {
    _currentState = TimerState.end;
    _stopWatchTimer.onStopTimer();
    int val = await _stopWatchTimer.rawTime.first;
    Map<String, dynamic> to_upload = {
      "datas" : historyDatas,
      "isCleared" : current_round == round + 1,
      "clearedRound" : current_round - 1,
      "timeTaken" : val,
      "displayTime" : StopWatchTimer.getDisplayTime(val, milliSecond: true)
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
        await leaderboardService.addLeaderboardEntry("timer_20_29", user.uid, to_upload_leaderboard);

      } else if(bestTime > to_upload["timeTaken"]){
        await userService.updateBestTime(to_upload["timeTaken"], to_upload["displayTime"]);
        await leaderboardService.addLeaderboardEntry("timer_20_29", user.uid, to_upload_leaderboard);
      }
    }


    //extra things
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timed Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            StreamBuilder<int>(
              stream: _stopWatchTimer.rawTime,
              initialData: 0,
              builder: (context, snapshot) {
                final value = snapshot.data!;
                String text_to_display = "", displayTime;
                if(_currentState == TimerState.play) {
                  displayTime = StopWatchTimer.getDisplayTime(
                      value, milliSecond: true);
                  text_to_display = displayTime;
                } else if (_currentState == TimerState.start){
                  displayTime = bestDisplayTime;
                  text_to_display = "Best Time : $displayTime";
                } else{
                  displayTime = StopWatchTimer.getDisplayTime(
                      value, milliSecond: true);
                  text_to_display = "Time Taken : $displayTime";
                }
                return Text(text_to_display, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),);
              },
            ),
            _buildContent(),
            if (_currentState == TimerState.play)
              PopScope(
                canPop: false,
                onPopInvoked: (bool didPop) async {
                  if (didPop) {
                    return;
                  }
                  await _handleBackPressed();
                },
                child: ElevatedButton(
                  onPressed: () async {
                    await _handleBackPressed();
                  },
                  child: const Text('Stop'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentState) {
      case TimerState.start:
        return _buildStartState();
      case TimerState.play:
        return _buildPlayState();
      case TimerState.end:
        return _buildEndState();
      default:
        return _buildStartState();
    }
  }

  Widget _buildStartState() {
    return ElevatedButton(
      onPressed: _startTimer,
      child: Text('Start'),
    );
  }

  Widget _buildPlayState() {
    int numNumberRows = (numbers.length / 5).ceil();

    return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Target: ${target.toInt()}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Wrap numbers with SingleChildScrollView
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  direction: Axis.horizontal,
                  children: List.generate(numNumberRows, (rowIndex) {
                    int startIndex = rowIndex * 5;
                    int endIndex = startIndex + 5 < numbers.length ? startIndex + 5 : numbers.length;
                    return ToggleButtons(
                      isSelected: isSelected.sublist(startIndex, endIndex),
                      onPressed: (int index) {
                        setState(() {
                          handleNumber(index + startIndex);
                        });
                      },
                      children: [
                        for (int i = startIndex; i < endIndex; i++)
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                              color: isSelected[i] ? Colors.blue : null,
                            ),
                            child: Text(
                              numbers[i] - numbers[i].toInt() == 0 ? numbers[i].toStringAsFixed(0) : numbers[i].toStringAsFixed(3),
                              style: TextStyle(
                                fontSize: 15,
                                color: isSelected[i] ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
              SizedBox(height: 20),
              // Use Wrap widget to display operator buttons
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  for (String operator in operators)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentOperator = operator;
                        });
                      },
                      child: Text(operator, style: TextStyle(fontSize: 20)),
                      style: ButtonStyle(
                        backgroundColor: currentOperator == operator
                            ? MaterialStateProperty.all(Colors.blue)
                            : null,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await applyOperator(currentOperator);
                },
                child: Text('Apply Operator'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: undo,
                child: Text('Undo'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: reset,
                child: Text('Reset'),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildEndState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _initState();
            });
          },
          child: Text('Restart'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    super.dispose();
  }
}
