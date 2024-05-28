import 'package:flutter/material.dart';
import 'package:aritmatika/pages/ClassicPage.dart';

class BitwiseSettingPage extends StatefulWidget {
  @override
  _BitwiseSettingPageState createState() => _BitwiseSettingPageState();
}

class _BitwiseSettingPageState extends State<BitwiseSettingPage> {
  final TextEditingController _nController = TextEditingController(text: '4');
  final TextEditingController _minTargetController = TextEditingController(text: '10');
  final TextEditingController _maxTargetController = TextEditingController(text: '99');

  int _numberOfNumbers = 4;

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
        title: Text('Bitwise Game Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text('How many numbers? '),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_numberOfNumbers > 2) {
                        _numberOfNumbers--;
                        _nController.text = _numberOfNumbers.toString();
                      }
                    });
                  },
                ),
                Text('$_numberOfNumbers'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      if (_numberOfNumbers < 10) {
                        _numberOfNumbers++;
                        _nController.text = _numberOfNumbers.toString();
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
              validator: _validateTargetMin,
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
              validator: _validateTargetMax,
            ),
            Text(
              _validateTargetMax(_maxTargetController.text) ?? '',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_validateNumberOfNumbers(_nController.text) == null &&
                    _validateTargetMin(_minTargetController.text) == null &&
                    _validateTargetMax(_maxTargetController.text) == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassicPage(
                        "Bitwise",
                        int.parse(_nController.text),
                        int.parse(_minTargetController.text),
                        int.parse(_maxTargetController.text),
                        ["<<", ">>", "&", "|", "^"]
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
