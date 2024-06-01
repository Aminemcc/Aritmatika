import 'package:flutter/material.dart';
import 'package:aritmatika/utils/Solver.dart';
import 'package:aritmatika/utils/SolverInt.dart';

class SolverPage extends StatefulWidget {
  final double? target;
  final List<int>? numbers;
  final List<String>? operators;
  SolverPage({this.target, this.numbers, this.operators});

  @override
  _SolverPageState createState() => _SolverPageState();
}

class _SolverPageState extends State<SolverPage> {
  final _formKey = GlobalKey<FormState>();
  int infinity = - (1 << 31) + 1;
  TextEditingController _targetNumberController = TextEditingController();
  List<TextEditingController> _numberControllers = [];
  List<int> _numbers = [];
  Solver solver = Solver();
  SolverInt solverInt = SolverInt();
  final int maxRows = 8;
  bool _isSolving = false;
  bool _solutionExists = true;
  List<String> _solutions = [];
  int countSelectedOperators = 4;
  bool integerOnlyMode = false;
  List<bool> isSelected = [];
  List<String> operators = ['+', '-', '*', '/', '**', '//', '%', '<<', '>>', '&', '|', '^'];
  List<String> operatorSymbols1 = ['+', '-', '*', '/', '**', '//'];
  List<String> operatorSymbols2 = ['%', '<<', '>>', '&', '|', '^'];

  @override
  void initState() {
    super.initState();
    _targetNumberController.text = (widget.target ?? 24).toInt().toString();
    _numberControllers = (widget.numbers ?? [-1, -1, -1, -1])
        .map((number) => TextEditingController(text: number == -1 ? "": number.toString()))
        .toList();
    isSelected = List.generate(operators.length ?? 4, (index) {
      if (widget.operators != null && widget.operators!.contains(operators[index])) {
        return true;
      } else if (widget.operators == null){
        return index < 4; // Default value for the first 4 operators
      } else{
        return false;
      }
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.target != null && widget.numbers != null && widget.operators != null) {
        _solve();
      }
    });
  }
  
  @override
  void dispose() {
    _targetNumberController.dispose();
    for (var controller in _numberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solver Page'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildTargetNumberForm(),
              SizedBox(height: 20.0),
              _buildNumberInputs(),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _isSolving ? null : _solve,
                child: _isSolving
                    ? CircularProgressIndicator()
                    : Text('Solve'),
              ),
              SizedBox(height: 20.0),
              _buildSolutions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetNumberForm() {
    return Form(
      key: _formKey, // Assign the form key
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                ToggleButtons(
                  children: operatorSymbols1.map((symbol) => Text(symbol)).toList(),
                  isSelected: isSelected.sublist(0, operatorSymbols1.length),
                  onPressed: (int index) {
                    setState(() {
                      if(countSelectedOperators > 1 || !isSelected[index]) {
                        countSelectedOperators += 1 - 2 * (isSelected[index] ? 1 : 0);
                        isSelected[index] = !isSelected[index];
                        print(getSelectedOperators());
                      }
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                ToggleButtons(
                  children: operatorSymbols2.map((symbol) => Text(symbol)).toList(),
                  isSelected: isSelected.sublist(operatorSymbols1.length),
                  onPressed: (int index) {
                    setState(() {
                      index += operatorSymbols1.length;
                      if(countSelectedOperators > 1 || !isSelected[index]) {
                        countSelectedOperators += 1 - 2 * (isSelected[index] ? 1 : 0);
                        isSelected[index] = !isSelected[index];
                      }
                    });
                  },
                ),
              ],
            ),
            ToggleButtons(
                children : [Text('Integer Only Mode')],
                isSelected : [integerOnlyMode],
                onPressed: (int index){
                  setState(() {
                    integerOnlyMode = !integerOnlyMode;
                  });
                }
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _targetNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Target Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the target number';
                }
                return null;
              },
              onSaved: (value) {
                // No need to save the target number as it's handled directly
                // in the _solve method
              },
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildNumberInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        _numberControllers.length,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _numberControllers[index],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number ${index + 1}',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // No need to save the numbers here
                  },
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _numberControllers.removeAt(index);
                  });
                },
              ),
            ],
          ),
        ),
      )..add(
        _numberControllers.length < maxRows
            ? Row(
          children: [
            Expanded(
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _numberControllers.add(TextEditingController());
                  });
                },
              ),
            ),
          ],
        )
            : SizedBox(),
      ),
    );
  }

  void _solve() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _numbers.clear();
      for (var controller in _numberControllers) {
        var number = int.tryParse(controller.text) ?? infinity;
        _numbers.add(number);
      }
      if (_numbers.any((number) => number == infinity)) {
        // Show error if any number field is empty or zero
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All number fields must be filled.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          _isSolving = true;
          _solutionExists = true;
        });
        List<String> selectedOperators = getSelectedOperators();
        if(!integerOnlyMode) {
          _solutions = solver.solve(
              _numbers, double.parse(_targetNumberController.text),
              selectedOperators); // Pass target number
        } else{
          _solutions = solverInt.solve(_numbers, int.parse(_targetNumberController.text), selectedOperators);
        }
        setState(() {
          _isSolving = false;
          _solutionExists = _solutions.isNotEmpty;
        });
      }
    }
  }

  List<String> getSelectedOperators(){
    List<String> selectedOperators = List.generate(operators.length, (index) {
      return isSelected[index] ? operators[index] : 'dummy';
    }).where((element) => element != 'dummy').toList();
    return selectedOperators;
  }

  Widget _buildSolutions() {
    if (_solutions.isEmpty) {
      return Center(
        child: Text(
          'No solution exists.',
          style: TextStyle(fontSize: 16.0),
        ),
      );
    }
    if (_solutions[0] == 'Max Iteration Reached') {
      return Center(
        child: Text(
          'Max Iteration Reached',
          style: TextStyle(fontSize: 16.0),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: _solutions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_solutions[index]),
          );
        },
      ),
    );
  }
}
