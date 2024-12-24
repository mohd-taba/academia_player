import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RandomPositionText extends StatefulWidget {
  final Duration duration;

  const RandomPositionText({
    Key? key,
    this.duration = const Duration(seconds: 6),
  }) : super(key: key);

  @override
  _RandomPositionTextState createState() => _RandomPositionTextState();
}

class _RandomPositionTextState extends State<RandomPositionText> with SingleTickerProviderStateMixin {
  String text = "";
  late AnimationController _controller;
  late Animation<Offset> _animation;
  final Random _random = Random();
  Size? screenSize;

  @override
  void initState() {
    getUserId();
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animateToRandomPosition();
      }
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) => _animateToRandomPosition());
  }

  void _animateToRandomPosition() {
    screenSize = MediaQuery.of(context).size;
    final double maxX = screenSize!.width / 2;
    final double maxY = screenSize!.height / 2;

    final double dx = _random.nextDouble() * maxX * (maxX < 0 ? -1 : 1);
    final double dy = _random.nextDouble() * maxY * (maxY < 0 ? -1 : 1);

    setState(() {
      _animation = Tween<Offset>(
        begin: _animation.value,
        end: Offset(dx / maxX, dy / maxY),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    });

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    text = prefs.getString('user_id') ?? "test";
  }

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value.dx * _screenSize.width / 2,
              _animation.value.dy * _screenSize.height / 2),
          child: Center(child: Text(text, style: const TextStyle(color: Colors.pinkAccent),)),
        );
      },
    );
  }
}
