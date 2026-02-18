import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// A simple bouncing ball demo screen.
///
/// Demonstrates basic Flutter animation concepts that can be applied to
/// geographic visualizations on the Liquid Galaxy.
class BouncingBallScreen extends StatefulWidget {
  const BouncingBallScreen({super.key});

  @override
  State<BouncingBallScreen> createState() => _BouncingBallScreenState();
}

class _BouncingBallScreenState extends State<BouncingBallScreen> {
  double _x = 100;
  double _y = 100;
  double _dx = 3;
  double _dy = 2;
  final double _radius = 20;
  Timer? _timer;
  bool _isRunning = false;

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        final size = MediaQuery.of(context).size;
        _x += _dx;
        _y += _dy;

        if (_x - _radius <= 0 || _x + _radius >= size.width) {
          _dx = -_dx;
        }
        if (_y - _radius <= 0 || _y + _radius >= size.height - 200) {
          _dy = -_dy;
        }

        _x = _x.clamp(_radius, size.width - _radius);
        _y = _y.clamp(_radius, size.height - 200 - _radius);
      });
    });
    setState(() => _isRunning = true);
  }

  void _stopAnimation() {
    _timer?.cancel();
    _timer = null;
    setState(() => _isRunning = false);
  }

  void _resetBall() {
    _stopAnimation();
    setState(() {
      _x = 100;
      _y = 100;
      _dx = 3;
      _dy = 2;
    });
  }

  void _randomizeDirection() {
    final random = Random();
    setState(() {
      _dx = (random.nextDouble() * 6 - 3).clamp(-5, 5);
      _dy = (random.nextDouble() * 6 - 3).clamp(-5, 5);
      if (_dx.abs() < 1) _dx = 2;
      if (_dy.abs() < 1) _dy = 2;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bouncing Ball'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: _x - _radius,
                    top: _y - _radius,
                    child: Container(
                      width: _radius * 2,
                      height: _radius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: _isRunning ? _stopAnimation : _startAnimation,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pause' : 'Start'),
                ),
                OutlinedButton.icon(
                  onPressed: _resetBall,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
                OutlinedButton.icon(
                  onPressed: _randomizeDirection,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Randomize'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
