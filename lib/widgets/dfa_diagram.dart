import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/dfa.dart';

class DFADiagramPainter extends CustomPainter {
  final DFA dfa;
  final String title;
  final bool horizontalLayout;
  final Map<DFAState, Offset>? customPositions;
  final DFAState? currentState;
  final Set<DFAState>? visitedStates;
  final Set<DFATransition>? visitedTransitions;
  final String? currentSymbol;

  DFADiagramPainter(
    this.dfa,
    this.title, {
    this.horizontalLayout = false,
    this.customPositions,
    this.currentState,
    this.visitedStates,
    this.visitedTransitions,
    this.currentSymbol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Calculate positions for states
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;
    final stateRadius = 30.0;

    Map<DFAState, Offset> statePositions = {};

    if (customPositions != null && customPositions!.isNotEmpty) {
      // Use provided normalized positions (0-1 range) scaled to canvas size
      customPositions!.forEach((state, pos) {
        statePositions[state] =
            Offset(pos.dx * size.width, pos.dy * size.height);
      });
    } else if (horizontalLayout) {
      // Position states in a left-to-right row
      final gap = size.width / (dfa.states.length + 1);
      final y = center.dy;
      for (int i = 0; i < dfa.states.length; i++) {
        final x = gap * (i + 1);
        statePositions[dfa.states[i]] = Offset(x, y);
      }
    } else {
      // Position states in a circle
      for (int i = 0; i < dfa.states.length; i++) {
        final angle = (2 * math.pi * i) / dfa.states.length - math.pi / 2;
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        statePositions[dfa.states[i]] = Offset(x, y);
      }
    }

    // Draw transitions
    final arrowPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.fill;

    // Group transitions by (from, to) pair to handle multiple labels on same line
    Map<String, List<DFATransition>> transitionGroups = {};
    for (var transition in dfa.transitions) {
      final key = '${transition.from.id}-${transition.to.id}';
      transitionGroups.putIfAbsent(key, () => []).add(transition);
    }

    for (var transition in dfa.transitions) {
      final from = statePositions[transition.from]!;
      final to = statePositions[transition.to]!;

      // Check if this transition is visited
      // Compare by from/to IDs and symbol since transitions may be recreated
      bool isVisited = visitedTransitions?.any((t) =>
              t.from.id == transition.from.id &&
              t.to.id == transition.to.id &&
              t.symbol == transition.symbol) ??
          false;

      // Set color based on visited state
      paint.color = isVisited ? Colors.purple.shade400 : Colors.grey.shade700;
      arrowPaint.color =
          isVisited ? Colors.purple.shade400 : Colors.grey.shade700;
      paint.strokeWidth = isVisited ? 3 : 2;

      if (transition.from == transition.to) {
        // Self loop
        final loopCenter = Offset(from.dx, from.dy - stateRadius - 25);
        canvas.drawCircle(loopCenter, 20, paint);

        // Draw arrow
        _drawArrowHead(canvas, arrowPaint,
            Offset(loopCenter.dx + 15, loopCenter.dy), math.pi / 4);

        // Collect all symbols for this self-loop
        List<String> symbols = dfa.transitions
            .where((t) => t.from == transition.from && t.to == transition.to)
            .map((t) => t.symbol)
            .toList();

        // Draw combined label
        textPainter.text = TextSpan(
          text: symbols.join(', '),
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(loopCenter.dx - textPainter.width / 2,
              loopCenter.dy - stateRadius - 15),
        );
      } else {
        final dx = to.dx - from.dx;
        final dy = to.dy - from.dy;
        final angle = math.atan2(dy, dx);

        // Adjust start and end points to be at edge of circles
        final startPoint = Offset(
          from.dx + stateRadius * math.cos(angle),
          from.dy + stateRadius * math.sin(angle),
        );
        final endPoint = Offset(
          to.dx - stateRadius * math.cos(angle),
          to.dy - stateRadius * math.sin(angle),
        );

        // Check for reverse transition
        bool hasReverse = dfa.transitions
            .any((t) => t.from == transition.to && t.to == transition.from);

        // Get all symbols for this (from, to) pair
        List<String> symbols = dfa.transitions
            .where((t) => t.from == transition.from && t.to == transition.to)
            .map((t) => t.symbol)
            .toList();

        // Only draw line once per (from, to) pair
        String pairKey = '${transition.from.id}-${transition.to.id}';
        if (dfa.transitions.indexOf(transition) ==
            dfa.transitions
                .indexWhere((t) => '${t.from.id}-${t.to.id}' == pairKey)) {
          if (hasReverse) {
            // Draw curved line
            final controlOffset = 20.0;
            final controlPoint = Offset(
              (startPoint.dx + endPoint.dx) / 2 -
                  controlOffset * math.sin(angle),
              (startPoint.dy + endPoint.dy) / 2 +
                  controlOffset * math.cos(angle),
            );

            final path = Path()
              ..moveTo(startPoint.dx, startPoint.dy)
              ..quadraticBezierTo(
                controlPoint.dx,
                controlPoint.dy,
                endPoint.dx,
                endPoint.dy,
              );
            canvas.drawPath(path, paint);

            // Draw arrow head
            final arrowAngle = math.atan2(
              endPoint.dy - controlPoint.dy,
              endPoint.dx - controlPoint.dx,
            );
            _drawArrowHead(canvas, arrowPaint, endPoint, arrowAngle);

            // Label position on curve
            textPainter.text = TextSpan(
              text: symbols.join(', '),
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.white.withOpacity(0.8),
              ),
            );
            textPainter.layout();
            textPainter.paint(
              canvas,
              Offset(controlPoint.dx - textPainter.width / 2,
                  controlPoint.dy - textPainter.height / 2),
            );
          } else {
            // Straight line
            canvas.drawLine(startPoint, endPoint, paint);

            // Draw arrow head
            _drawArrowHead(canvas, arrowPaint, endPoint, angle);

            // Label at midpoint
            final midPoint = Offset(
              (startPoint.dx + endPoint.dx) / 2,
              (startPoint.dy + endPoint.dy) / 2,
            );

            textPainter.text = TextSpan(
              text: symbols.join(', '),
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.white.withOpacity(0.8),
              ),
            );
            textPainter.layout();
            textPainter.paint(
              canvas,
              Offset(midPoint.dx - textPainter.width / 2,
                  midPoint.dy - textPainter.height / 2 - 10),
            );
          }
        }
      }
    }

    // Draw states
    for (var state in dfa.states) {
      final pos = statePositions[state]!;

      // Check if this is the current state or visited
      // Compare by ID since DFAState == compares nfaStates, not ID
      bool isCurrent = currentState != null && currentState!.id == state.id;
      bool isVisitedState =
          visitedStates?.any((s) => s.id == state.id) ?? false;

      // Draw glow effect for current state
      if (isCurrent) {
        final glowPaint = Paint()
          ..color = Colors.amber.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, stateRadius + 10, glowPaint);
        final glowPaint2 = Paint()
          ..color = Colors.amber.withOpacity(0.5)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, stateRadius + 6, glowPaint2);
      }

      // Draw double circle for final states
      if (state.isFinal) {
        paint.color = isCurrent
            ? Colors.amber.shade700
            : isVisitedState
                ? Colors.green.shade400
                : Colors.green.shade700;
        fillPaint.color = isCurrent
            ? Colors.amber.shade50
            : isVisitedState
                ? Colors.green.shade100
                : Colors.green.shade50;
        canvas.drawCircle(pos, stateRadius, fillPaint);
        canvas.drawCircle(pos, stateRadius, paint);
        canvas.drawCircle(pos, stateRadius - 5, paint);
      } else if (state.id == 8) {
        // Dead state in red
        paint.color =
            isCurrent ? Colors.deepOrange.shade700 : Colors.red.shade700;
        fillPaint.color =
            isCurrent ? Colors.deepOrange.shade50 : Colors.red.shade50;
        canvas.drawCircle(pos, stateRadius, fillPaint);
        canvas.drawCircle(pos, stateRadius, paint);
      } else {
        paint.color = isCurrent
            ? Colors.amber.shade700
            : isVisitedState
                ? Colors.purple.shade300
                : state.isStart
                    ? Colors.blue.shade700
                    : Colors.grey.shade700;
        fillPaint.color = isCurrent
            ? Colors.amber.shade50
            : isVisitedState
                ? Colors.purple.shade50
                : state.isStart
                    ? Colors.blue.shade50
                    : Colors.grey.shade50;
        canvas.drawCircle(pos, stateRadius, fillPaint);
        canvas.drawCircle(pos, stateRadius, paint);
      }

      // Draw start arrow
      if (state.isStart) {
        final arrowStart = Offset(pos.dx - stateRadius - 40, pos.dy);
        final arrowEnd = Offset(pos.dx - stateRadius - 5, pos.dy);
        paint.color = Colors.blue.shade700;
        canvas.drawLine(arrowStart, arrowEnd, paint);
        _drawArrowHead(
            canvas, fillPaint..color = Colors.blue.shade700, arrowEnd, 0);
      }

      // Draw state label
      textPainter.text = TextSpan(
        text: state.toString(),
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }
  }

  void _drawArrowHead(Canvas canvas, Paint paint, Offset tip, double angle) {
    const arrowSize = 10.0;
    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - arrowSize * math.cos(angle - math.pi / 6),
      tip.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    path.lineTo(
      tip.dx - arrowSize * math.cos(angle + math.pi / 6),
      tip.dy - arrowSize * math.sin(angle + math.pi / 6),
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DFADiagramWidget extends StatelessWidget {
  final DFA dfa;
  final String title;
  final bool horizontalLayout;
  final Map<DFAState, Offset>? customPositions;
  final DFAState? currentState;
  final Set<DFAState>? visitedStates;
  final Set<DFATransition>? visitedTransitions;
  final String? currentSymbol;

  const DFADiagramWidget({
    super.key,
    required this.dfa,
    required this.title,
    this.horizontalLayout = false,
    this.customPositions,
    this.currentState,
    this.visitedStates,
    this.visitedTransitions,
    this.currentSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                size: Size.infinite,
                painter: DFADiagramPainter(dfa, title,
                    horizontalLayout: horizontalLayout,
                    customPositions: customPositions,
                    currentState: currentState,
                    visitedStates: visitedStates,
                    visitedTransitions: visitedTransitions,
                    currentSymbol: currentSymbol),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildLegendItem(Colors.blue.shade700, 'Start State'),
                const SizedBox(width: 20),
                _buildLegendItem(Colors.green.shade700, 'Final State'),
                const SizedBox(width: 20),
                _buildLegendItem(Colors.grey.shade700, 'Regular State'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            color: color.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
