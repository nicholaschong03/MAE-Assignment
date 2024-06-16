import 'package:flutter/material.dart';
import 'package:jom_eat_project/services/database_service.dart';

class SwipeToJoinOutingWidget extends StatefulWidget {
  final VoidCallback onRegistrationComplete;
  final String outingId;
  final String userId;

  const SwipeToJoinOutingWidget({
    super.key,
    required this.onRegistrationComplete,
    required this.outingId,
    required this.userId,
  });

  @override
  State<SwipeToJoinOutingWidget> createState() =>
      _SwipeToJoinOutingWidgetState();
}

class _SwipeToJoinOutingWidgetState extends State<SwipeToJoinOutingWidget>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.addListener(() {
      setState(() {
        _dragPosition = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _completeRegistration() async {
    try {
      await _dataService.joinOuting(widget.outingId, widget.userId);
      widget.onRegistrationComplete();
    } catch (e) {
      print("Error joining outing: $e");
      setState(() {
        _isCompleted = false; // Reset completion status if there is an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double buttonSize = 56;
    double containerWidth = MediaQuery.of(context).size.width - (2 * 16);
    double maxDragPosition = containerWidth - buttonSize - (2 * 4);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            // Background
            Container(
              height: 64,
              width: containerWidth,
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 36,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _isCompleted
                    ? Colors.green
                    : Color.fromARGB(255, 255, 102, 0),
                borderRadius: const BorderRadius.all(
                  Radius.circular(32),
                ),
              ),
              child: Center(
                child: Text(
                  _isCompleted ? 'You\'re In!' : 'Swipe to Join',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
            ),

            // Swipe to Join Button
            Positioned(
              left: _dragPosition,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragPosition += details.delta.dx;
                    if (_dragPosition < 0) {
                      _dragPosition = 0;
                    } else if (_dragPosition > maxDragPosition) {
                      _dragPosition = maxDragPosition;
                      _isCompleted = true;
                      _completeRegistration();
                    }
                  });
                },
                onHorizontalDragEnd: (details) {
                  if (!_isCompleted && _dragPosition < (maxDragPosition * 0.95)) {
                    _animation = Tween<double>(begin: _dragPosition, end: 0.0)
                        .animate(_animationController);
                    _animationController.forward(from: 0.0);
                  } else if (!_isCompleted) {
                    _animation = Tween<double>(
                      begin: _dragPosition,
                      end: maxDragPosition,
                    ).animate(_animationController);
                    _animationController.forward(from: 0.0);
                    _isCompleted = true;
                    _completeRegistration();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: buttonSize,
                  height: buttonSize,
                  margin: const EdgeInsets.only(
                    left: 16 + 4,
                    right: 16 + 4,
                    top: 4,
                  ),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 243, 243, 243), // Changed to orange
                    borderRadius: const BorderRadius.all(
                      Radius.circular(32),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward,
                      color: Color.fromARGB(255, 255, 102, 0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
