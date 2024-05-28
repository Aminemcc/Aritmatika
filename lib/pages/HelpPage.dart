import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to use the app:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'The game is simple, you are given some numbers, operators and a target to form using every number once.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'There are 5 Modes : Classic, Bitwise, Random, Custom and Solver\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Classic : + - * /',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Bitwise : << >> & | ^',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Random : Random operators',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Custom : Custom play the game',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Solver : Search for solutions',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '\nTo read solutions, here are the\nPrecedence Level : \n1. **\n2. *  /  //  %\n3.+  -\n4. <<  >>\n5. &\n 6. ^\n7. |',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '\nExamples:\n-) 2 ** 4 = 16\n-) 3 * 5 = 15\n-) 7 / 2 = 3.5'
              ),
              Text(
                '-) 7 // 2 = 3\n-) 7 % 2 = 1'
              ),
              Text(
                '-) 2 + 3 = 5\n-) 3 - 2 = 1'
              ),
              Text(
                  '-) 9 << 2 = 36, 1001 << 10 = 100100\n-) 9 >> 2 = 2, 1001 >> 10 = 10'
              ),
              Text(
                '-) '
              )
              // Add more text as needed
            ],
          ),
        ),
      ),
    );
  }
}
