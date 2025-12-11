import 'package:flutter/material.dart';
import '../providers/automata_provider.dart';
import '../models/nfa.dart';

class NFAPage extends StatelessWidget {
  const NFAPage({super.key});

  @override
  Widget build(BuildContext context) {
    final automataData = AutomataData();
    final nfa = automataData.nfa;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: const Text('NFA - Thompson\'s Construction',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: nfa == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.blue.shade600
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.blur_on,
                                    color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'NFA State Diagram',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/NFA.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(context, nfa),
                  const SizedBox(height: 24),
                  _buildTransitionTable(context, nfa),
                  const SizedBox(height: 24),
                  _buildAlgorithmDescription(context),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(BuildContext context, NFA nfa) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100.withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 8),
                Text(
                  'NFA Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Total States:', '${nfa.states.length}'),
            _buildInfoRow('Transitions:', '${nfa.transitions.length}'),
            _buildInfoRow('Start State:', nfa.startState.toString()),
            _buildInfoRow(
              'Final States:',
              nfa.finalStates.map((s) => s.toString()).join(', '),
            ),
            _buildInfoRow(
              'Alphabet:',
              '{${nfa.alphabet.join(', ')}}',
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

  Widget _buildTransitionTable(BuildContext context, NFA nfa) {
    // Get all unique symbols (inputs) including epsilon
    Set<String> symbolSet = {'ε'}; // Always include epsilon
    for (var transition in nfa.transitions) {
      symbolSet.add(transition.symbol);
    }
    List<String> symbols = symbolSet.toList()
      ..sort((a, b) {
        if (a == 'ε') return -1; // Put epsilon first
        if (b == 'ε') return 1;
        return a.compareTo(b);
      });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.table_chart, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'NFA Transition Table',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade400, width: 1),
                columnWidths: {
                  0: const FixedColumnWidth(60),
                  for (int i = 1; i <= symbols.length; i++)
                    i: const FixedColumnWidth(80),
                },
                children: [
                  // Header row with inputs
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blue.shade100),
                    children: [
                      _buildTableCell('State', isHeader: true),
                      ...symbols.map((s) => _buildTableCell(s, isHeader: true)),
                    ],
                  ),
                  // Data rows for each state
                  ...nfa.states.map((state) {
                    return TableRow(
                      children: [
                        _buildTableCell(state.toString(), isHeader: true),
                        ...symbols.map((symbol) {
                          // Find next states for this transition
                          var transitions = nfa.transitions
                              .where(
                                  (t) => t.from == state && t.symbol == symbol)
                              .map((t) => t.to.toString())
                              .toList();

                          String nextStates = transitions.isNotEmpty
                              ? transitions.join(', ')
                              : '-';

                          return _buildTableCell(nextStates);
                        }),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Thompson\'s Construction Algorithm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Thompson\'s Construction is an algorithm for converting a regular expression into a Non-deterministic Finite Automaton (NFA).',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.95),
                  height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Key Features:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Supports epsilon (ε) transitions'),
            _buildBulletPoint('Implements Kleene star (*) with loops'),
            _buildBulletPoint('Union (+) via epsilon transitions'),
            _buildBulletPoint('Linear time complexity O(n)'),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withOpacity(0.95)))),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.blue.shade900 : Colors.black,
          fontFamily: isHeader ? null : 'monospace',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
