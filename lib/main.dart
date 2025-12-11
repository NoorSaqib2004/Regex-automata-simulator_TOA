import 'package:flutter/material.dart';
import 'models/nfa.dart';
import 'models/dfa.dart';
import 'algorithms/thompson_construction.dart';
import 'algorithms/subset_construction.dart';
import 'algorithms/dfa_minimization.dart';
import 'screens/home_page.dart';
import 'screens/nfa_page.dart';
import 'screens/dfa_page.dart';
import 'screens/minimized_dfa_page.dart';
import 'screens/simulation_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RegEx Automata Simulator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/nfa': (context) => const NFAPage(),
        '/dfa': (context) => const DFAPage(),
        '/minimized': (context) => const MinimizedDFAPage(),
        '/simulation': (context) => const SimulationPage(),
      },
    );
  }
}

class AutomataSimulatorPage extends StatefulWidget {
  const AutomataSimulatorPage({super.key});

  @override
  State<AutomataSimulatorPage> createState() => _AutomataSimulatorPageState();
}

class _AutomataSimulatorPageState extends State<AutomataSimulatorPage> {
  final TextEditingController _inputController = TextEditingController();
  final String regularExpression = '(gh*g + hm*h + mg*m)gmg';

  NFA? nfa;
  DFA? dfa;
  DFA? minimizedDFA;
  List<Map<String, String>>? simulationSteps;
  bool? isAccepted;

  @override
  void initState() {
    super.initState();
    _buildAutomata();
  }

  void _buildAutomata() {
    try {
      print('Building NFA...');
      // Step 1: Build NFA using Thompson's Construction
      ThompsonConstruction thompson = ThompsonConstruction();
      nfa = thompson.buildNFA();
      print('NFA built with ${nfa!.states.length} states');

      print('Converting to DFA...');
      // Step 2: Convert NFA to DFA using Subset Construction
      SubsetConstruction subsetConstruction = SubsetConstruction();
      dfa = subsetConstruction.convertNFAtoDFA(nfa!);
      print('DFA built with ${dfa!.states.length} states');

      print('Minimizing DFA...');
      // Step 3: Minimize DFA
      DFAMinimization minimization = DFAMinimization();
      minimizedDFA = minimization.minimize(dfa!);
      print('Minimized DFA built with ${minimizedDFA!.states.length} states');

      setState(() {});
      print('Automata built successfully!');
    } catch (e, stackTrace) {
      print('ERROR building automata: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _simulateString() {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a string to test')),
      );
      return;
    }

    String input = _inputController.text;

    // Simulate on minimized DFA
    simulationSteps = minimizedDFA!.getSimulationSteps(input);
    isAccepted = minimizedDFA!.simulate(input);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Regular Expression Automata Simulator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            _buildInputSection(),
            const SizedBox(height: 24),

            // NFA Table
            _buildSectionTitle('NFA Transition Table'),
            _buildNFATable(),
            const SizedBox(height: 24),

            // DFA Table
            _buildSectionTitle('DFA Transition Table'),
            _buildDFATable(dfa, 'DFA'),
            const SizedBox(height: 24),

            // Minimized DFA Table
            _buildSectionTitle('Minimized DFA Transition Table'),
            _buildDFATable(minimizedDFA, 'Minimized DFA'),
            const SizedBox(height: 24),

            // Simulation Section
            if (simulationSteps != null) ...[
              _buildSectionTitle('String Simulation Steps'),
              _buildSimulationSteps(),
              const SizedBox(height: 16),
              _buildResult(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regular Expression',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                regularExpression,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Test String',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter string to test (e.g., ghggmg)',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _simulateString,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Simulate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
      ),
    );
  }

  Widget _buildNFATable() {
    if (nfa == null) return const CircularProgressIndicator();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start State: ${nfa!.startState}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Final States: ${nfa!.finalStates.map((s) => s.toString()).join(", ")}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DataTable(
                border: TableBorder.all(color: Colors.grey.shade300),
                headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
                columns: const [
                  DataColumn(
                      label: Text('State',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Symbol',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Next State(s)',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _buildNFARows(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildNFARows() {
    List<DataRow> rows = [];

    for (var state in nfa!.states) {
      List<NFATransition> stateTransitions =
          nfa!.transitions.where((t) => t.from == state).toList();

      if (stateTransitions.isEmpty) {
        rows.add(DataRow(cells: [
          DataCell(Text(state.toString())),
          const DataCell(Text('-')),
          const DataCell(Text('-')),
        ]));
      } else {
        for (int i = 0; i < stateTransitions.length; i++) {
          var transition = stateTransitions[i];
          rows.add(DataRow(cells: [
            DataCell(Text(i == 0 ? state.toString() : '')),
            DataCell(Text(transition.symbol)),
            DataCell(Text(transition.to.toString())),
          ]));
        }
      }
    }

    return rows;
  }

  Widget _buildDFATable(DFA? dfa, String label) {
    if (dfa == null) return const CircularProgressIndicator();

    var transitionTable = dfa.getTransitionTable();
    List<String> symbols = dfa.alphabet.toList()..sort();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start State: ${dfa.startState}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Final States: ${dfa.finalStates.map((s) => s.toString()).join(", ")}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DataTable(
                border: TableBorder.all(color: Colors.grey.shade300),
                headingRowColor: WidgetStateProperty.all(Colors.green.shade100),
                columns: [
                  const DataColumn(
                      label: Text('State',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  ...symbols.map((s) => DataColumn(
                        label: Text(s,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      )),
                  const DataColumn(
                      label: Text('Type',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: dfa.states.map((state) {
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        state.toString(),
                        style: TextStyle(
                          fontWeight: state.isStart
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: state.isStart ? Colors.blue : Colors.black,
                        ),
                      )),
                      ...symbols.map((symbol) {
                        return DataCell(Text(
                            transitionTable[state.toString()]?[symbol] ?? '-'));
                      }),
                      DataCell(Text(
                        state.isFinal
                            ? 'Final'
                            : (state.isStart ? 'Start' : ''),
                        style: TextStyle(
                          color: state.isFinal ? Colors.green : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimulationSteps() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input String: "${_inputController.text}"',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: simulationSteps!.length,
              itemBuilder: (context, index) {
                var step = simulationSteps![index];
                bool isLastStep = index == simulationSteps!.length - 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLastStep
                        ? (isAccepted!
                            ? Colors.green.shade50
                            : Colors.red.shade50)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isLastStep
                          ? (isAccepted! ? Colors.green : Colors.red)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          'Step ${step['step']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step['description']!,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: isLastStep
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Card(
      elevation: 4,
      color: isAccepted! ? Colors.green.shade100 : Colors.red.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAccepted! ? Icons.check_circle : Icons.cancel,
              color: isAccepted! ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              'Result: ${isAccepted! ? "ACCEPTED" : "REJECTED"}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    isAccepted! ? Colors.green.shade900 : Colors.red.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
