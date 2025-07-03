import 'package:flutter/material.dart';
import 'package:gamypad/widgets/game_button.dart';
import 'package:gamypad/classes/stateManager.dart';

enum dir { up, down, left, right, none }

class Dpad extends StatefulWidget {
  const Dpad({super.key, this.onDirectionChanged});

  final ValueChanged<Statemanager>? onDirectionChanged;

  @override
  State<Dpad> createState() => _DpadState();
}

class _DpadState extends State<Dpad> {
  final ValueNotifier<Statemanager> _activeDirections = ValueNotifier(
    Statemanager(),
  );

  @override
  void dispose() {
    _activeDirections.dispose();
    super.dispose();
  }

  // Check Direction
  void _updateDirections(Offset localPosition, Size containerSize) {
    updateDirections(
      localPosition,
      containerSize,
      _activeDirections,
      widget.onDirectionChanged,
    );
  }

  void _clearDirections() {
    clearDirections(_activeDirections, widget.onDirectionChanged);
  }

  @override
  Widget build(BuildContext context) {
    Size targetSize = const Size(
      60,
      50,
    ); // Still used for individual button sizing

    return Container(
      margin: const EdgeInsets.all(8),
      width: 200,
      height: 170,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerSize = constraints.biggest;
          return GestureDetector(
            onPanStart: (details) =>
                _updateDirections(details.localPosition, containerSize),
            onPanUpdate: (details) =>
                _updateDirections(details.localPosition, containerSize),
            onPanEnd: (details) => _clearDirections(),
            onTapDown: (details) =>
                _updateDirections(details.localPosition, containerSize),
            onTapUp: (details) => _clearDirections(),
            onLongPressDown: (details) =>
                _updateDirections(details.localPosition, containerSize),
            onLongPressEnd: (details) => _clearDirections(),

            child: Stack(
              alignment: Alignment.center,
              children: [
                ValueListenableBuilder<Statemanager>(
                  valueListenable: _activeDirections,
                  builder: (context, activeState, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // UP button
                        GameButtons(
                          label: "UP",
                          btnColor: activeState.up ? Colors.blue : Colors.grey,
                          btnSize: targetSize,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LEFT button
                            GameButtons(
                              label: "LEFT",
                              btnColor: activeState.left
                                  ? Colors.blue
                                  : Colors.grey,
                              btnSize: targetSize,
                            ),

                            SizedBox(
                              width: targetSize.width,
                            ), // To push right button
                            // RIGHT button
                            GameButtons(
                              label: "RIGHT",
                              btnColor: activeState.right
                                  ? Colors.blue
                                  : Colors.grey,
                              btnSize: targetSize,
                            ),
                          ],
                        ),

                        // DOWN button
                        GameButtons(
                          label: "DOWN",
                          btnColor: activeState.down
                              ? Colors.blue
                              : Colors.grey,
                          btnSize: targetSize,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
