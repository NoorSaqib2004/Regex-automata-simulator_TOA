import 'package:flutter/material.dart';
import '../models/dfa.dart';
import '../models/nfa.dart';
import '../widgets/dfa_diagram.dart';

class DFAPage extends StatelessWidget {
  const DFAPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dfa = _buildProvidedDFA();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: const Text('DFA - Minimized DFA',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DFADiagramWidget(
              dfa: dfa,
              title: 'DFA State Diagram',
              horizontalLayout: true,
              customPositions: _buildPositions(dfa),
            ),
            const SizedBox(height: 12),
            _buildLegend(context),
            const SizedBox(height: 24),
            _buildInfoCard(context, dfa),
            const SizedBox(height: 24),
            _buildTransitionTable(context, dfa),
            const SizedBox(height: 24),
            _buildAlgorithmDescription(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dead state legend
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade700, width: 2),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Dead State (S8)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, dfa) {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DFA Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Total States:', '${dfa.states.length}'),
            _buildInfoRow('Transitions:', '${dfa.transitions.length}'),
            _buildInfoRow('Start State:', dfa.startState.toString()),
            _buildInfoRow(
              'Final States:',
              dfa.finalStates.map((s) => s.toString()).join(', '),
            ),
            _buildInfoRow(
              'Alphabet:',
              '{${dfa.alphabet.join(', ')}}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionTable(BuildContext context, dfa) {
    var transitionTable = dfa.getTransitionTable();
    List<String> symbols = dfa.alphabet.toList()..sort();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DFA Transition Table',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade400, width: 1),
                columnWidths: {
                  0: const FixedColumnWidth(60),
                  for (int i = 1; i <= symbols.length; i++)
                    i: const FixedColumnWidth(70),
                  symbols.length + 1: const FixedColumnWidth(70),
                },
                children: [
                  // Header row with inputs and type
                  TableRow(
                    decoration: BoxDecoration(color: Colors.green.shade100),
                    children: [
                      _buildTableCell('State', isHeader: true),
                      ...symbols.map((s) => _buildTableCell(s, isHeader: true)),
                      _buildTableCell('Type', isHeader: true),
                    ],
                  ),
                  // Data rows for each state
                  ...dfa.states.map((state) {
                    String stateType = '';
                    if (state.isFinal && state.isStart) {
                      stateType = 'Start\nFinal';
                    } else if (state.isFinal) {
                      stateType = 'Final';
                    } else if (state.isStart) {
                      stateType = 'Start';
                    } else {
                      stateType = '';
                    }

                    return TableRow(
                      children: [
                        _buildTableCell(
                          state.toString(),
                          isHeader: true,
                          isBold: state.isStart,
                          color: state.isStart ? Colors.blue.shade700 : null,
                        ),
                        ...symbols.map((symbol) {
                          String nextState =
                              transitionTable[state.toString()]?[symbol] ?? '-';
                          return _buildTableCell(nextState);
                        }),
                        _buildTableCell(
                          stateType,
                          color: state.isFinal
                              ? Colors.green.shade700
                              : (state.isStart ? Colors.blue.shade700 : null),
                          isBold: stateType.isNotEmpty,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithmDescription(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subset Construction Algorithm',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Subset Construction converts an NFA into a DFA by treating sets of NFA states as single DFA states.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Key Features:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            _buildBulletPoint('No epsilon transitions'),
            _buildBulletPoint('Exactly one transition per symbol per state'),
            _buildBulletPoint('Deterministic execution'),
            _buildBulletPoint('May have more states than NFA'),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isHeader ? Colors.green.shade900 : Colors.black),
          fontFamily: isHeader ? null : 'monospace',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  DFA _buildProvidedDFA() {
    final states = <_NamedDFAState>[
      _NamedDFAState(0, isStart: true),
      _NamedDFAState(1),
      _NamedDFAState(2),
      _NamedDFAState(3),
      _NamedDFAState(4),
      _NamedDFAState(5),
      _NamedDFAState(6),
      _NamedDFAState(7, isFinal: true),
      _NamedDFAState(8), // Dead state
    ];

    final deadState = states[8];

    final transitions = <DFATransition>[
      // Original transitions
      DFATransition(states[0], states[1], 'g'),
      DFATransition(states[0], states[2], 'h'),
      DFATransition(states[0], states[3], 'm'),
      DFATransition(states[1], states[1], 'h'),
      DFATransition(states[1], states[4], 'g'),
      DFATransition(states[2], states[2], 'm'),
      DFATransition(states[2], states[4], 'h'),
      DFATransition(states[3], states[3], 'g'),
      DFATransition(states[3], states[4], 'm'),
      DFATransition(states[4], states[5], 'g'),
      DFATransition(states[5], states[6], 'm'),
      DFATransition(states[6], states[7], 'g'),

      // Missing transitions to dead state
      DFATransition(
          states[0], deadState, 'NONE'), // placeholder, will be replaced
      DFATransition(states[1], deadState, 'm'),
      DFATransition(
          states[1], deadState, 'g'), // S1 needs g to somewhere or dead
      DFATransition(states[2], deadState, 'g'),
      DFATransition(
          states[2], deadState, 'h'), // S2 needs h to somewhere or dead
      DFATransition(states[3], deadState, 'm'),
      DFATransition(
          states[3], deadState, 'h'), // S3 needs h to somewhere or dead
      DFATransition(states[4], deadState, 'h'),
      DFATransition(states[4], deadState, 'm'),
      DFATransition(states[5], deadState, 'g'),
      DFATransition(states[5], deadState, 'h'),
      DFATransition(states[6], deadState, 'h'),
      DFATransition(states[6], deadState, 'm'),
      DFATransition(states[7], deadState, 'g'),
      DFATransition(states[7], deadState, 'h'),
      DFATransition(states[7], deadState, 'm'),

      // Dead state self-loops
      DFATransition(deadState, deadState, 'g'),
      DFATransition(deadState, deadState, 'h'),
      DFATransition(deadState, deadState, 'm'),
    ];

    // Remove the placeholder transition
    transitions.removeWhere((t) => t.symbol == 'NONE');

    return DFA(
      states: states,
      transitions: transitions,
      startState: states.firstWhere((s) => s.isStart),
      finalStates: states.where((s) => s.isFinal).toList(),
      alphabet: {'g', 'h', 'm'},
    );
  }

  Map<DFAState, Offset> _buildPositions(DFA dfa) {
    // Normalized positions (fractions of width/height) tuned to match the provided diagram
    final layout = <String, Offset>{
      'S0': const Offset(0.08, 0.55),
      'S1': const Offset(0.20, 0.20),
      'S2': const Offset(0.20, 0.55),
      'S3': const Offset(0.20, 0.90),
      'S4': const Offset(0.45, 0.55),
      'S5': const Offset(0.65, 0.55),
      'S6': const Offset(0.80, 0.55),
      'S7': const Offset(0.92, 0.55),
      'S8': const Offset(0.55, 0.10), // Dead state at top center
    };

    final positions = <DFAState, Offset>{};
    for (final state in dfa.states) {
      final pos = layout[state.toString()];
      if (pos != null) {
        positions[state] = pos;
      }
    }
    return positions;
  }
}

class _NamedDFAState extends DFAState {
  _NamedDFAState(int id, {bool isStart = false, bool isFinal = false})
      : super({NFAState(id)}, id, isStart: isStart, isFinal: isFinal);

  @override
  String toString() => 'S$id';
}
