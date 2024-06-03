import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:aritmatika/utils/Generator.dart';
import 'package:aritmatika/utils/SolverUtility.dart';
import 'package:aritmatika/services/HistoryService.dart';
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
  Map<String, dynamic> historyData = {};
  String historyId = '';
  bool isSolved = false;

  TimerState _currentState = TimerState.start;
  int _clickCount = 0;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    current_round = 1;
    _currentState = TimerState.start;
    gameDatas.clear();
    fetchGameData();
    newNumbers(1);
    _stopWatchTimer.onResetTimer();
    historyData = {
      "numbers": startNumbers,
      "target": target,
      "operators": operators,
      "isSolved": isSolved
    };
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
    startNumbers = gameData['numbers'];
    target = gameData['target'].toDouble();
    numbers.addAll(startNumbers.map<double>((e) => e.toDouble()).toList());
    isSelected = List.generate(numbers.length, (index) => false);
    undoNumbers.add(List.from(numbers));
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
    _stopWatchTimer.rawTime.listen((value) {
      final displayTime = StopWatchTimer.getDisplayTime(value, milliSecond: true);
      print('Time: $displayTime');
      print(value);

    });

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

  void applyOperator(String operator) {
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
        ++current_round;
        if(current_round > round){
          endGame();
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

  void endGame(){
    _currentState = TimerState.end;
    _stopWatchTimer.onStopTimer();
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
                final displayTime = StopWatchTimer.getDisplayTime(value, milliSecond: true);
                return Text('$displayTime', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),);
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
                onPressed: () {
                  applyOperator(currentOperator);
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
        StreamBuilder<int>(
          stream: _stopWatchTimer.rawTime,
          initialData: 0,
          builder: (context, snapshot) {
            final value = snapshot.data!;
            final displayTime = StopWatchTimer.getDisplayTime(value, milliSecond: true);
            return Text('Time taken: $displayTime');
          },
        ),
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
