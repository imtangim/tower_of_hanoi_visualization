import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

void main() {
  runApp(GetMaterialApp(home: TowerOfHanoiApp()));
}

class TowerOfHanoiApp extends StatelessWidget {
  const TowerOfHanoiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tower of Hanoi - Recursion Debugger")),
      body: TowerOfHanoiWidget(discCount: 5),
    );
  }
}

class TowerOfHanoiWidget extends StatefulWidget {
  final int discCount;

  const TowerOfHanoiWidget({super.key, required this.discCount});

  @override
  State<TowerOfHanoiWidget> createState() => _TowerOfHanoiWidgetState();
}

class _TowerOfHanoiWidgetState extends State<TowerOfHanoiWidget> {
  List<List<int>> towers = [[], [], []]; // Three pegs
  List<List<int>> moves = [];
  List<String> recursionStack = []; // Stack of function calls
  List<String> moveLogs = []; // Move history
  int highlightedLine = -1; // Line being executed
  double delay = 800; // Default delay in ms
  bool isSolving = false;
  Completer<void>? moveCompleter;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    setState(() {
      towers = [
        List.generate(widget.discCount, (index) => widget.discCount - index),
        [],
        []
      ];
      moves.clear();
      moveLogs.clear();
      recursionStack.clear();
      highlightedLine = -1;
      isSolving = false;
    });
  }

  Future<void> solve() async {
    if (isSolving) return;

    setState(() {
      isSolving = true;
      moves.clear();
      moveLogs.clear();
      recursionStack.clear();
      highlightedLine = -1;
    });

    // First generate all moves
    generateMoves(widget.discCount, 0, 2, 1);

    // Then execute the moves with animation
    await executeMoves();

    setState(() {
      isSolving = false;
    });
  }

  void generateMoves(int n, int from, int to, int aux) {
    if (n == 1) {
      moves.add([from, to]);
      return;
    }

    generateMoves(n - 1, from, aux, to);
    moves.add([from, to]);
    generateMoves(n - 1, aux, to, from);
  }

  Future<void> executeMoves() async {
    for (int i = 0; i < moves.length; i++) {
      int from = moves[i][0];
      int to = moves[i][1];

      // Determine which part of the algorithm we're in
      await showRecursionState(i);

      // Get the disk that will be moved
      int disk = towers[from].isNotEmpty ? towers[from].last : -1;

      // Show the planned move
      setState(() {
        moveLogs.add(
            "⏳ Moving disk $disk from Peg ${from + 1} to Peg ${to + 1}...");
      });

      // Wait for delay
      await Future.delayed(Duration(milliseconds: delay.toInt()));

      // Execute the move
      setState(() {
        if (towers[from].isNotEmpty) {
          int movedDisk = towers[from].removeLast();
          towers[to].add(movedDisk);
          moveLogs.add(
              "✅ Moved disk $movedDisk from Peg ${from + 1} to Peg ${to + 1}");
        }
      });

      // Small pause between moves
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  Future<void> showRecursionState(int moveIndex) async {
    if (moveIndex == 0) {
      setState(() {
        recursionStack.clear();
        recursionStack.add("hanoi(${widget.discCount}, Peg 1, Peg 3, Peg 2)");
        highlightedLine = 0;
      });
      await Future.delayed(Duration(milliseconds: delay ~/ 2));

      setState(() {
        highlightedLine = 1;
      });
      await Future.delayed(Duration(milliseconds: delay ~/ 2));
    }

    setState(() {
      if (moveIndex % 2 == 0) {
        highlightedLine = 5;
      } else {
        highlightedLine = 2;
      }
    });
    await Future.delayed(Duration(milliseconds: delay ~/ 2));

    if (moveIndex < moves.length - 1) {
      setState(() {
        if (moveIndex % 2 == 0) {
          highlightedLine = 6;
        } else {
          highlightedLine = 4;
        }
      });
      await Future.delayed(Duration(milliseconds: delay ~/ 2));
    }
  }

  bool _showCodeVisualizer = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  // Pegs
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) => buildPeg(index)),
                    ),
                  ),
                  if (!isMobile) ...[
                    // Code Simulation (only show on desktop)
                    Expanded(child: buildCodePanel()),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              // mainAxisAlignment: MainAxisAlignment.center,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isSolving ? null : () => solve(),
                  child: Text("Solve"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isSolving ? null : resetGame,
                  child: Text("Reset"),
                ),
                if (isMobile) ...[
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          _showCodeVisualizer = !_showCodeVisualizer;
                        });
                      }
                    },
                    child: Text(_showCodeVisualizer
                        ? "Hide Code Visualizer"
                        : "Show Code Visualizer"),
                  ),
                ]
              ],
            ),
            SizedBox(height: 10),
            // Execution Speed Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Speed: "),
                Slider(
                  value: delay,
                  min: 100,
                  max: 2000,
                  divisions: 19,
                  label: "${delay.toInt()} ms",
                  onChanged: (value) {
                    setState(() {
                      delay = value;
                    });
                  },
                ),
              ],
            ),
            // Move Logs
            if (_showCodeVisualizer) ...[
              // Code Simulation (only show on desktop)
              Expanded(
                flex: 3,
                child: buildCodePanel(),
              ),
            ] else ...[
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  color: Colors.black87,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: moveLogs
                          .map((log) => Text(
                                log,
                                style: TextStyle(color: Colors.white),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ]
          ],
        );
      },
    );
  }

  Widget buildPeg(int index) {
    return Container(
      width: 100,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: List.generate(towers[index].length, (i) {
          int discSize = towers[index][i];
          return Positioned(
            bottom: i * 20.0, // Stack the discs on top of each other
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              width: discSize * 20.0,
              height: 20,
              decoration: BoxDecoration(
                color: getDiscColor(discSize),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  '$discSize',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Color getDiscColor(int size) {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];
    return colors[size % colors.length];
  }

  Widget buildCodePanel() {
    List<String> codeLines = [
      "def hanoi(n, from_peg, to_peg, aux_peg):",
      "    if n == 1:",
      "        move_disk(from_peg, to_peg)",
      "        return",
      "    hanoi(n-1, from_peg, aux_peg, to_peg)", // First recursive call
      "    move_disk(from_peg, to_peg)",
      "    hanoi(n-1, aux_peg, to_peg, from_peg)" // Second recursive call
    ];

    return SingleChildScrollView(
      child: Container(
        color: Colors.black87,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Recursion Stack:",
                style: TextStyle(
                    color: Colors.yellow, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.black54,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: recursionStack
                    .map((call) => Text(
                          call,
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'monospace'),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Algorithm:",
                style: TextStyle(
                    color: Colors.yellow, fontWeight: FontWeight.bold),
              ),
            ),
            ...codeLines.asMap().entries.map((entry) {
              int lineNumber = entry.key;
              String code = entry.value;

              return Container(
                color: highlightedLine == lineNumber
                    ? Colors.red
                    : Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                child: Text(
                  "${highlightedLine == lineNumber ? '-->' : '   '} $code",
                  style: TextStyle(
                    color: highlightedLine == lineNumber
                        ? Colors.white
                        : Colors.green,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
