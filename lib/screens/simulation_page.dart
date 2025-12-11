import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/automata_provider.dart';
import '../models/dfa.dart';
import '../models/nfa.dart';
import '../widgets/dfa_diagram.dart';

class SimulationPage extends StatefulWidget {
  const SimulationPage({super.key});

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final automataData = AutomataData();
  final String regularExpression = '(gh*g + hm*h + mg*m)gmg';
  List<Map<String, String>>? simulationSteps;
  bool? isAccepted;

  // Animation state
  late AnimationController _animationController;
  int _currentStep = 0;
  bool _isPlaying = false;
  double _animationSpeed = 1.0;
  DFAState? _currentState;
  Set<DFAState> _visitedStates = {};
  Set<DFATransition> _visitedTransitions = {};

  // Cached DFA to avoid recreation
  late DFA _cachedDFA;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isPlaying) {
        _stepForward();
      }
    });

    // Build DFA once and cache it
    _cachedDFA = _buildProvidedDFA();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _simulateString() {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a string to test')),
      );
      return;
    }

    String input = _inputController.text;

    setState(() {
      simulationSteps = _cachedDFA.getSimulationSteps(input);
      isAccepted = _cachedDFA.simulate(input);
    });

    // Reset animation after setState to ensure proper update
    _resetAnimation();
    setState(() {}); // Force rebuild with new animation state
  }

  void _resetAnimation() {
    _currentStep = 0;
    _isPlaying = false;
    _visitedStates = {};
    _visitedTransitions = {};
    _animationController.reset();

    // Set initial state and update to first step
    if (simulationSteps != null && simulationSteps!.isNotEmpty) {
      _updateAnimationState();
    }
  }

  void _playPauseAnimation() {
    setState(() {
      if (_isPlaying) {
        _isPlaying = false;
        _animationController.stop();
      } else {
        _isPlaying = true;
        _stepForward();
      }
    });
  }

  void _stepForward() {
    if (simulationSteps == null ||
        _currentStep >= simulationSteps!.length - 1) {
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    setState(() {
      _currentStep++;
      _updateAnimationState();
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _stepBackward() {
    if (_currentStep <= 0) return;

    setState(() {
      _currentStep--;
      _updateAnimationState();
      _isPlaying = false;
      _animationController.reset();
    });
  }

  void _updateAnimationState() {
    if (simulationSteps == null || simulationSteps!.isEmpty) return;

    final step = simulationSteps![_currentStep];

    // Parse state ID from 'nextState' (format: "Dxx" where xx is the ID)
    String stateStr = step['nextState']!;
    if (stateStr == 'None') {
      // If no next state, stay at current
      return;
    }

    // Extract numeric ID from state string (e.g., "D0" -> 0, "D8" -> 8)
    final stateId = int.parse(stateStr.substring(1));

    _currentState = _cachedDFA.states.firstWhere((s) => s.id == stateId);
    _visitedStates.add(_currentState!);

    // Add transition if not first step
    if (_currentStep > 0 && step['symbol'] != '-') {
      final prevStep = simulationSteps![_currentStep - 1];
      String prevStateStr = prevStep['nextState']!;
      if (prevStateStr != 'None') {
        final prevStateId = int.parse(prevStateStr.substring(1));
        final prevState =
            _cachedDFA.states.firstWhere((s) => s.id == prevStateId);
        final symbol = step['symbol']!;

        // Find the transition
        try {
          final transition = _cachedDFA.transitions.firstWhere(
            (t) =>
                t.from == prevState &&
                t.to == _currentState &&
                t.symbol == symbol,
          );
          _visitedTransitions.add(transition);
        } catch (e) {
          // Transition not found, continue
        }
      }
    }
  }

  void _setAnimationSpeed(double speed) {
    setState(() {
      _animationSpeed = speed;
      _animationController.duration =
          Duration(milliseconds: (800 / speed).round());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        title: const Text('String Simulation'),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildRegexSection()),
            const SizedBox(height: 24),
            _buildInputSection(),
            if (isAccepted != null) ...[
              const SizedBox(height: 16),
              _buildQuickResult(),
            ],
            const SizedBox(height: 24),
            if (simulationSteps != null) ...[
              _buildSimulationSteps(),
              const SizedBox(height: 16),
              _buildResult(),
              const SizedBox(height: 24),
            ],
            _buildDFADiagram(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.deepPurple.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Test String Input (g, h, m only)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[ghm]')),
                    ],
                    onChanged: (value) {
                      setState(() {}); // Update on input change
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.deepPurple.shade400, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.text_fields),
                      prefixIconColor: Colors.deepPurple.shade700,
                      suffixText: '${_inputController.text.length} chars',
                      suffixStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                      hintText: 'e.g., gggmg, ghggmg, hhgmg',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _simulateString,
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Simulate',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Example valid strings: ggmg, ghggmg, hhgmg, mmgmg',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickResult() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAccepted!
              ? [Colors.green.shade400, Colors.green.shade500]
              : [Colors.red.shade400, Colors.red.shade500],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isAccepted! ? Colors.green.shade300 : Colors.red.shade300)
                .withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAccepted! ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Result',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAccepted! ? "ACCEPTED ✓" : "REJECTED ✗",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_downward,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationSteps() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.timeline,
                      color: Colors.indigo.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Step-by-Step Simulation',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Input String: "${_inputController.text}"',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'monospace',
                  color: Colors.indigo.shade900,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: simulationSteps!.length,
              itemBuilder: (context, index) {
                var step = simulationSteps![index];
                bool isLastStep = index == simulationSteps!.length - 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isLastStep
                        ? LinearGradient(
                            colors: isAccepted!
                                ? [Colors.green.shade50, Colors.green.shade100]
                                : [Colors.red.shade50, Colors.red.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isLastStep ? null : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLastStep
                          ? (isAccepted!
                              ? Colors.green.shade400
                              : Colors.red.shade400)
                          : Colors.grey.shade200,
                      width: isLastStep ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLastStep
                              ? (isAccepted!
                                  ? Colors.green.shade600
                                  : Colors.red.shade600)
                              : Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Step ${step['step']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          step['description']!,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight:
                                isLastStep ? FontWeight.bold : FontWeight.w500,
                            color: Colors.grey.shade800,
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAccepted!
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isAccepted! ? Colors.green.shade200 : Colors.red.shade200)
                .withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAccepted! ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Result',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAccepted! ? "ACCEPTED ✓" : "REJECTED ✗",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegexSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade200.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.code, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Regular Expression',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              regularExpression,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color: Colors.deepPurple.shade700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDFADiagram() {
    return Column(
      children: [
        // Add animation controls if simulation is running
        if (simulationSteps != null && simulationSteps!.isNotEmpty) ...[
          _buildAnimationControls(),
          const SizedBox(height: 16),
        ],
        DFADiagramWidget(
          dfa: _cachedDFA,
          title: 'Minimized DFA State Diagram',
          horizontalLayout: true,
          customPositions: _buildPositions(_cachedDFA),
          currentState: _currentState,
          visitedStates: _visitedStates,
          visitedTransitions: _visitedTransitions,
        ),
        const SizedBox(height: 12),
        _buildLegend(),
      ],
    );
  }

  Widget _buildAnimationControls() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current step indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade50, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.deepPurple.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Step ${_currentStep + 1}/${simulationSteps!.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                    if (_currentState != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'S${_currentState!.id}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    if (_currentStep < simulationSteps!.length &&
                        simulationSteps![_currentStep]['symbol'] != '-') ...[
                      const SizedBox(width: 8),
                      Text(
                        '"${simulationSteps![_currentStep]['symbol']}"',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Control buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reset button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade600, Colors.grey.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.replay, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _resetAnimation();
                        });
                      },
                      tooltip: 'Reset',
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Step backward button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: _currentStep > 0 ? _stepBackward : null,
                      tooltip: 'Step Backward',
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Play/Pause button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: _playPauseAnimation,
                      tooltip: _isPlaying ? 'Pause' : 'Play',
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Step forward button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: _currentStep < simulationSteps!.length - 1
                          ? _stepForward
                          : null,
                      tooltip: 'Step Forward',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Speed slider
            Row(
              children: [
                Icon(Icons.speed, color: Colors.deepPurple.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _animationSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 3,
                    label: '${_animationSpeed.toStringAsFixed(1)}x',
                    activeColor: Colors.deepPurple.shade600,
                    onChanged: _setAnimationSpeed,
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${_animationSpeed.toStringAsFixed(1)}x',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade600, width: 2),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Dead State (S8)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
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
      // S0 valid transitions (start state)
      DFATransition(states[0], states[1], 'g'),
      DFATransition(states[0], states[2], 'h'),
      DFATransition(states[0], states[3], 'm'),

      // S1 valid transitions
      DFATransition(states[1], states[1], 'h'),
      DFATransition(states[1], states[4], 'g'),
      // S1 invalid transitions go to dead state
      DFATransition(states[1], deadState, 'm'),

      // S2 valid transitions
      DFATransition(states[2], states[2], 'm'),
      DFATransition(states[2], states[4], 'h'),
      // S2 invalid transitions go to dead state
      DFATransition(states[2], deadState, 'g'),

      // S3 valid transitions
      DFATransition(states[3], states[3], 'g'),
      DFATransition(states[3], states[4], 'm'),
      // S3 invalid transitions go to dead state
      DFATransition(states[3], deadState, 'h'),

      // S4 valid transitions
      DFATransition(states[4], states[5], 'g'),
      // S4 invalid transitions go to dead state
      DFATransition(states[4], deadState, 'h'),
      DFATransition(states[4], deadState, 'm'),

      // S5 valid transitions
      DFATransition(states[5], states[6], 'm'),
      // S5 invalid transitions go to dead state
      DFATransition(states[5], deadState, 'g'),
      DFATransition(states[5], deadState, 'h'),

      // S6 valid transitions
      DFATransition(states[6], states[7], 'g'),
      // S6 invalid transitions go to dead state
      DFATransition(states[6], deadState, 'h'),
      DFATransition(states[6], deadState, 'm'),

      // S7 (final state) - all transitions go to dead state
      DFATransition(states[7], deadState, 'g'),
      DFATransition(states[7], deadState, 'h'),
      DFATransition(states[7], deadState, 'm'),

      // Dead state self-loops
      DFATransition(deadState, deadState, 'g'),
      DFATransition(deadState, deadState, 'h'),
      DFATransition(deadState, deadState, 'm'),
    ];

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
