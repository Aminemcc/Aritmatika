import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

enum TimerState { start, play, end }

class TimedHomePage extends StatefulWidget {
  const TimedHomePage();

  @override
  _TimedHomePageState createState() => _TimedHomePageState();
}

class _TimedHomePageState extends State<TimedHomePage> {
  TimerState _currentState = TimerState.start;
  int _clickCount = 0;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );

  void _startTimer() {
    setState(() {
      _currentState = TimerState.play;
      _clickCount = 0;
      _stopWatchTimer.onResetTimer();
      _stopWatchTimer.onStartTimer();
    });
  }

  void _buttonClicked() {
    setState(() {
      _clickCount++;
      if (_clickCount == 10) {
        _currentState = TimerState.end;
        _stopWatchTimer.onStopTimer();
      }
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
        return Container();
    }
  }

  Widget _buildStartState() {
    return ElevatedButton(
      onPressed: _startTimer,
      child: Text('Start'),
    );
  }

  Widget _buildPlayState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Click the button 10 times'),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _buttonClicked,
          child: Text('Click Me'),
        ),
        SizedBox(height: 20),
        Text('Clicks: $_clickCount/10'),
        SizedBox(height: 20),
        StreamBuilder<int>(
          stream: _stopWatchTimer.rawTime,
          initialData: 0,
          builder: (context, snapshot) {
            final value = snapshot.data!;
            final displayTime = StopWatchTimer.getDisplayTime(value, milliSecond: true);
            return Text('Time: $displayTime');
          },
        ),
      ],
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
              _currentState = TimerState.start;
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
