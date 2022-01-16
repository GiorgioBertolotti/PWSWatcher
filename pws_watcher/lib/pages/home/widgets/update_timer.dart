import 'package:flutter/material.dart';

class UpdateTimer extends StatefulWidget {
  UpdateTimer(this.duration, this.callBack);

  final Duration duration;
  final Function callBack;

  @override
  _UpdateTimerState createState() => _UpdateTimerState();
}

class _UpdateTimerState extends State<UpdateTimer>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Duration? _actualDuration;

  @override
  void initState() {
    super.initState();
    _actualDuration = widget.duration;
    startTimer();
  }

  void startTimer() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller!.addListener(() {
      if (_controller!.value > 0.99) {
        widget.callBack();
      }
    });
    _controller!.repeat();
    _actualDuration = widget.duration;
  }

  void restartTimer() {
    if (_controller != null) {
      _controller!.stop();
      _controller!.dispose();
    }
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller!.addListener(() {
      if (_controller!.value > 0.99) {
        widget.callBack();
      }
    });
    _controller!.repeat();
    _actualDuration = widget.duration;
  }

  @override
  void dispose() {
    if (_controller != null) _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_actualDuration != widget.duration) {
      restartTimer();
    }
    return Container(
      margin: EdgeInsets.all(16.0),
      width: 16.0,
      height: 16.0,
      child: AnimatedBuilder(
          animation: _controller!,
          builder: (context, snapshot) {
            return CircularProgressIndicator(
              value: _controller!.value,
              strokeWidth: 2.5,
            );
          }),
    );
  }
}
