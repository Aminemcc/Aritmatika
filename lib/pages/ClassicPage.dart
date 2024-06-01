import 'package:flutter/material.dart';
import 'package:aritmatika/utils/Generator.dart';
import 'package:aritmatika/utils/SolverUtility.dart';

class ClassicPage extends StatefulWidget {
  final String mode;
  final int n;
  final int targetMin;
  final int targetMax;
  final List<String> operators;
  ClassicPage(this.mode, this.n, this.targetMin, this.targetMax, this.operators, {super.key});

  @override
  _ClassicPageState createState() => _ClassicPageState();
}

class _ClassicPageState extends State<ClassicPage> {
  final Generator generator = Generator();
  final SolverUtility util = SolverUtility();

  Map<String, dynamic> gameData = {};
  List<List<double>> undoNumbers = [];
  List<double> numbers = [];
  List<int> startNumbers = [];
  String currentOperator = '';
  double target = 0;
  List<bool> isSelected = [];
  List<int> selectedIndexes = [];
  bool updatedSelection = false;

  @override
  void initState() {
    super.initState();
    fetchGameData();
  }

  void fetchGameData() {
    setState(() {
      numbers.clear();
      undoNumbers.clear();
      selectedIndexes.clear();
      gameData = generator.generate(widget.n, 1, 13, widget.targetMin, widget.targetMax, widget.operators, false);
      startNumbers = gameData['numbers'];
      target = gameData['target'].toDouble();
      numbers.addAll(startNumbers.map<double>((e) => e.toDouble()).toList());
      isSelected = List.generate(numbers.length, (index) => false);
      undoNumbers.add(List.from(numbers)); // Save initial numbers state
    });
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

  void applyOperator(String operator) {
    try {
      if (selectedIndexes.length < 2 || !widget.operators.contains(operator)) {
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

      setState(() {}); // Update the UI after all state changes
    } catch (e) {
      return;
    }
  }

  void showSolution() {
    String solution = gameData['solution'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Solution'),
          content: Text(solution),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Calculate the number of rows needed based on the number of numbers
    int numNumberRows = (numbers.length / 5).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mode}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              print("TEST");
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => HomePage()),
              // );
            },
          ),
        ],
      ),
      body: Center(
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
                  for (String operator in widget.operators)
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchGameData,
                child: Text('New'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: showSolution,
                child: Text('Show Solution'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
