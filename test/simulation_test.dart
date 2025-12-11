import 'package:flutter_test/flutter_test.dart';
import 'package:regex_automata_simulator/models/dfa.dart';
import 'package:regex_automata_simulator/models/nfa.dart';

// Helper class to create test DFA (same structure as in simulation_page.dart)
class _NamedDFAState extends DFAState {
  _NamedDFAState(int id, {bool isStart = false, bool isFinal = false})
      : super({NFAState(id)}, id, isStart: isStart, isFinal: isFinal);

  @override
  String toString() => 'D$id';
}

DFA buildTestDFA() {
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
    DFATransition(states[1], deadState, 'm'),
    DFATransition(states[2], deadState, 'g'),
    DFATransition(states[3], deadState, 'h'),
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

  return DFA(
    states: states,
    transitions: transitions,
    startState: states.firstWhere((s) => s.isStart),
    finalStates: states.where((s) => s.isFinal).toList(),
    alphabet: {'g', 'h', 'm'},
  );
}

void main() {
  group('DFA Simulation Tests for (gh*g + hm*h + mg*m)gmg', () {
    late DFA dfa;

    setUp(() {
      dfa = buildTestDFA();
    });

    test('Accept valid strings', () {
      // Test examples from corrected EXAMPLES.md
      expect(dfa.simulate('gggmg'), true,
          reason: 'gh*g path: g, g (h* = empty), then gmg');
      expect(dfa.simulate('ghggmg'), true,
          reason: 'gh*g path: g, h, g, then gmg');
      expect(dfa.simulate('hhgmg'), true,
          reason: 'hm*h path: h, h (m* = empty), then gmg');
      expect(dfa.simulate('hmhgmg'), true,
          reason: 'hm*h path: h, m, h, then gmg');
      expect(dfa.simulate('hmmhgmg'), true,
          reason: 'hm*h path: h, m, m, h, then gmg');
      expect(dfa.simulate('mmgmg'), true,
          reason: 'mg*m path: m, m (g* = empty), then gmg');
      expect(dfa.simulate('mgmgmg'), true,
          reason: 'mg*m path: m, g, m, then gmg');
      expect(dfa.simulate('mgggmgmg'), true,
          reason: 'mg*m path: m, g, g, g, m, then gmg');
      expect(dfa.simulate('ghhhhggmg'), true,
          reason: 'gh*g path with multiple h');
    });

    test('Reject invalid strings', () {
      // Strings that don't match the pattern
      expect(dfa.simulate('ggmg'), false,
          reason: 'Missing one g - should be gggmg');
      expect(dfa.simulate('gmg'), false, reason: 'Missing first pattern part');
      expect(dfa.simulate('gg'), false, reason: 'Incomplete pattern');
      expect(dfa.simulate('ghg'), false, reason: 'Missing gmg suffix');
      expect(dfa.simulate('ggmm'), false, reason: 'Wrong suffix');
      expect(dfa.simulate('ghgmh'), false, reason: 'Wrong ending');
      expect(dfa.simulate('mhmgmg'), false,
          reason: 'Wrong first symbol for hm*h pattern');
      expect(dfa.simulate('hghgmg'), false,
          reason: 'Wrong middle symbol for hm*h pattern');
      expect(dfa.simulate('ghmgmg'), false,
          reason: 'Mixing patterns incorrectly');
      expect(dfa.simulate(''), false, reason: 'Empty string');
    });

    test('All valid paths reach final state', () {
      // Verify the structure: paths should be (pattern)gmg where pattern is one of:
      // gh*g, hm*h, or mg*m

      // gh*g variants
      expect(dfa.simulate('gggmg'), true); // gh*g where h*=empty
      expect(dfa.simulate('ghggmg'), true); // gh*g where h*=h
      expect(dfa.simulate('ghhggmg'), true); // gh*g where h*=hh

      // hm*h variants
      expect(dfa.simulate('hhgmg'), true); // hm*h where m*=empty
      expect(dfa.simulate('hmhgmg'), true); // hm*h where m*=m
      expect(dfa.simulate('hmmhgmg'), true); // hm*h where m*=mm

      // mg*m variants
      expect(dfa.simulate('mmgmg'), true); // mg*m where g*=empty
      expect(dfa.simulate('mgmgmg'), true); // mg*m where g*=g
      expect(dfa.simulate('mggmgmg'), true); // mg*m where g*=gg
    });

    test('Verify simulation steps structure', () {
      final steps = dfa.getSimulationSteps('ggmg');

      // Should have steps: Start, g, g, m, g, End
      expect(steps.length, greaterThan(0));
      expect(steps.first['step'], 'Start');
      expect(steps.last['step'], 'End');

      // Check each step has required keys
      for (var step in steps) {
        expect(step.containsKey('step'), true);
        expect(step.containsKey('state'), true);
        expect(step.containsKey('symbol'), true);
        expect(step.containsKey('nextState'), true);
        expect(step.containsKey('description'), true);
      }
    });

    test('Dead state transitions work correctly', () {
      // Test strings that should go to dead state
      expect(dfa.simulate('gm'), false,
          reason: 'Should go to dead state from D1 with m');
      expect(dfa.simulate('hg'), false,
          reason: 'Should go to dead state from D2 with g');
      expect(dfa.simulate('mh'), false,
          reason: 'Should go to dead state from D3 with h');

      // Verify dead state is reached and stays
      final steps = dfa.getSimulationSteps('gm');
      expect(steps.any((s) => s['nextState'] == 'D8'), true,
          reason: 'Should reach dead state D8');
    });

    test('Verify state transitions match expected path', () {
      // Test gggmg: D0 -> D1 -> D4 -> D5 -> D6 -> D7
      final steps = dfa.getSimulationSteps('gggmg');

      // Filter out Start and End steps
      final transitionSteps = steps
          .where((s) => s['step'] != 'Start' && s['step'] != 'End')
          .toList();

      expect(transitionSteps.length, 5); // 5 symbols
      expect(transitionSteps[0]['state'], 'D0'); // Start at D0
      expect(transitionSteps[0]['nextState'], 'D1'); // g -> D1
      expect(transitionSteps[1]['state'], 'D1'); // At D1
      expect(transitionSteps[1]['nextState'], 'D4'); // g -> D4
      expect(transitionSteps[2]['state'], 'D4'); // At D4
      expect(transitionSteps[2]['nextState'], 'D5'); // g -> D5
      expect(transitionSteps[3]['state'], 'D5'); // At D5
      expect(transitionSteps[3]['nextState'], 'D6'); // m -> D6
      expect(transitionSteps[4]['state'], 'D6'); // At D6
      expect(transitionSteps[4]['nextState'], 'D7'); // g -> D7 (final)
    });
  });
}
