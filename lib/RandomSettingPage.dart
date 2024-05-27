import 'package:flutter/material.dart';
import 'RandomPage.dart';

class RandomSettingPage extends StatefulWidget {
  @override
  _RandomSettingPageState createState() => _RandomSettingPageState();
}

class _RandomSettingPageState extends State<RandomSettingPage> {
  final TextEditingController _nMinController = TextEditingController(text: '4');
  final TextEditingController _nMaxController = TextEditingController(text: '6');
  int _numberOfNumbersMin = 4;
  int _numberOfNumbersMax = 6;

  final TextEditingController _nOpeMinController = TextEditingController(text: '4');
  final TextEditingController _nOpeMaxController = TextEditingController(text: '6');
  int _nOpeMinForm = 4;
  int _nOpeMaxForm = 6;

  final TextEditingController _minTargetController = TextEditingController(text: '10');
  final TextEditingController _maxTargetController = TextEditingController(text: '99');

  int _nMin = 3;
  int _nMax = 10;
  int _nOpeMin = 3;
  int _nOpeMax = 12;

  String? _validateNumberOfNumbers(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the number of numbers';
    }
    int intValue = int.tryParse(value) ?? 0;
    if (intValue < 2 || intValue > 10) {
      return 'Number of numbers must be between 2 and 10';
    }
    return null;
  }

  String? _validateTargetMin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the minimum target';
    }
    int intValue = int.tryParse(value) ?? 0;
    int maxTarget = int.tryParse(_maxTargetController.text) ?? 0;
    if (intValue >= maxTarget || maxTarget - intValue < 9) {
      return 'Minimum target must be less than maximum target and the difference must be at least 9';
    }
    return null;
  }

  String? _validateTargetMax(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the maximum target';
    }
    int intValue = int.tryParse(value) ?? 0;
    int minTarget = int.tryParse(_minTargetController.text) ?? 0;
    if (intValue <= minTarget || intValue - minTarget < 9) {
      return 'Maximum target must be greater than minimum target and the difference must be at least 9';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Game Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text('Minimum N Numbers '),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_numberOfNumbersMin > _nMin) {
                        _numberOfNumbersMin--;
                        _nMinController.text = _numberOfNumbersMin.toString();
                      }
                    });
                  },
                ),
                Text('$_numberOfNumbersMin'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      if (_numberOfNumbersMin < _numberOfNumbersMax) {
                        _numberOfNumbersMin++;
                        _nMinController.text = _numberOfNumbersMin.toString();
                      } else if (_numberOfNumbersMax < _nMax) {
                        _numberOfNumbersMin++;
                        _nMinController.text = _numberOfNumbersMin.toString();
                        _numberOfNumbersMax++;
                        _nMaxController.text = _numberOfNumbersMax.toString();
                      }
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text('Maximum N Numbers '),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_numberOfNumbersMax > _numberOfNumbersMin) {
                        _numberOfNumbersMax--;
                        _nMaxController.text = _numberOfNumbersMax.toString();
                      } else if (_numberOfNumbersMin > _nMin) {
                        _numberOfNumbersMin--;
                        _nMinController.text = _numberOfNumbersMin.toString();
                        _numberOfNumbersMax--;
                        _nMaxController.text = _numberOfNumbersMax.toString();
                      }
                    });
                  },
                ),
                Text('$_numberOfNumbersMax'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      if (_numberOfNumbersMax < _nMax) {
                        _numberOfNumbersMax++;
                        _nMaxController.text = _numberOfNumbersMax.toString();
                      }
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text('Minimum N Operators '),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_nOpeMinForm > _nOpeMin) {
                        _nOpeMinForm--;
                        _nOpeMinController.text = _nOpeMinForm.toString();
                      }
                    });
                  },
                ),
                Text('$_nOpeMinForm'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      if (_nOpeMinForm < _nOpeMaxForm) {
                        _nOpeMinForm++;
                        _nOpeMinController.text = _nOpeMinForm.toString();
                      } else if (_nOpeMinForm < _nOpeMax) {
                        _nOpeMinForm++;
                        _nOpeMinController.text = _nOpeMinForm.toString();
                        _nOpeMaxForm++;
                        _nOpeMaxController.text = _nOpeMaxForm.toString();
                      }
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text('Maximum N Operators '),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_nOpeMaxForm > _nOpeMinForm) {
                        _nOpeMaxForm--;
                        _nOpeMaxController.text = _nOpeMaxForm.toString();
                      } else if (_nOpeMinForm > _nOpeMin) {
                        _nOpeMinForm--;
                        _nOpeMinController.text = _nOpeMinForm.toString();
                        _nOpeMaxForm--;
                        _nOpeMaxController.text = _nOpeMaxForm.toString();
                      }
                    });
                  },
                ),
                Text('$_nOpeMaxForm'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      if (_nOpeMaxForm < _nOpeMax) {
                        _nOpeMaxForm++;
                        _nOpeMaxController.text = _nOpeMaxForm.toString();
                      }
                    });
                  },
                ),
              ],
            ),
            TextFormField(
              controller: _minTargetController,
              decoration: InputDecoration(labelText: 'Minimum Target'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  // Call the validator function after the value changes
                  _validateTargetMin(value);
                });
              },
              validator: _validateTargetMin, // Added validator
            ),
            Text(
              _validateTargetMin(_minTargetController.text) ?? '',
              style: TextStyle(color: Colors.red),
            ),
            TextFormField(
              controller: _maxTargetController,
              decoration: InputDecoration(labelText: 'Maximum Target'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  // Call the validator function after the value changes
                  _validateTargetMax(value);
                });
              },
              validator: _validateTargetMax, // Added validator
            ),
            Text(
              _validateTargetMax(_maxTargetController.text) ?? '',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_validateNumberOfNumbers(_nMinController.text) == null &&
                    _validateNumberOfNumbers(_nMaxController.text) == null &&
                    _validateTargetMin(_minTargetController.text) == null &&
                    _validateTargetMax(_maxTargetController.text) == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RandomPage(
                          _numberOfNumbersMin,
                          _numberOfNumbersMax,
                          _nOpeMinForm,
                          _nOpeMaxForm,
                          int.parse(_minTargetController.text),
                          int.parse(_maxTargetController.text),
                      ),
                    ),
                  );
                }
              },
              child: Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
