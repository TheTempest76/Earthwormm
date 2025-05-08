import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class TaskCompletionSlider extends StatefulWidget {
  final VoidCallback? onComplete;

  const TaskCompletionSlider({
    Key? key,
    this.onComplete,
  }) : super(key: key);

  @override
  _TaskCompletionSliderState createState() => _TaskCompletionSliderState();
}

class _TaskCompletionSliderState extends State<TaskCompletionSlider>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  bool _isCompleted = false;
  bool _isDragging = false;
  late ConfettiController _confettiController;
  late AnimationController _checkmarkController;
  late Animation<double> _checkmarkAnimation;

  // Define colors
  final Color _lightGreen = const Color(0xFF90EE90);
  final Color _darkGreen = const Color(0xFF006400);

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _checkmarkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  void _handleComplete() async {
    if (!_isCompleted) {
      setState(() {
        _isCompleted = true;
        _progress = 1.0; // Set progress to 100%
      });

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }

      _checkmarkController.forward();
      _confettiController.play();
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sliderHeight = 60.0;
    final containerPadding = 20.0;

    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth - (containerPadding * 2);
      final circlePosition = _isCompleted
          ? maxWidth - sliderHeight // Move to very end when completed
          : _progress * (maxWidth - sliderHeight); // Normal dragging position

      return Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: [
                _darkGreen,
                _lightGreen,
                Colors.greenAccent,
              ],
            ),
          ),
          Container(
            height: sliderHeight,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: containerPadding),
            child: GestureDetector(
              onHorizontalDragStart: (_) => setState(() => _isDragging = true),
              onHorizontalDragEnd: (_) {
                setState(() => _isDragging = false);
                if (_progress > 0.7) {
                  _handleComplete();
                } else {
                  setState(() => _progress = 0.0);
                }
              },
              onHorizontalDragUpdate: (details) {
                if (!_isCompleted) {
                  final double newProgress =
                      (_progress + details.delta.dx / (maxWidth - sliderHeight))
                          .clamp(0.0, 1.0);
                  setState(() => _progress = newProgress);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(sliderHeight / 2),
                ),
                child: Stack(
                  children: [
                    // Progress background
                    FractionallySizedBox(
                      widthFactor: _progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _lightGreen.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(sliderHeight / 2),
                        ),
                      ),
                    ),

                    // Slider thumb or checkmark
                    Positioned(
                      left: circlePosition,
                      child: _isCompleted
                          ? AnimatedBuilder(
                              animation: _checkmarkAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: sliderHeight,
                                  height: sliderHeight,
                                  decoration: BoxDecoration(
                                    color: _darkGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: (sliderHeight * 0.6) *
                                        _checkmarkAnimation.value,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: sliderHeight,
                              height: sliderHeight,
                              decoration: BoxDecoration(
                                color: _darkGreen,
                                shape: BoxShape.circle,
                                boxShadow: _isDragging
                                    ? [
                                        BoxShadow(
                                          color: _darkGreen.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: sliderHeight * 0.6,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// Center(child: TaskCompletionSlider(
//         onComplete: () {
//           print('Task completed!');
//           // Add your completion logic here
//         },
//       )),