import 'nfa.dart';

// DFA State class
class DFAState {
  final Set<NFAState> nfaStates;
  final int id;
  bool isStart;
  bool isFinal;

  DFAState(this.nfaStates, this.id,
      {this.isStart = false, this.isFinal = false});

  @override
  String toString() => 'D$id';

  @override
  bool operator ==(Object other) {
    if (other is! DFAState) return false;
    return nfaStates.length == other.nfaStates.length &&
        nfaStates.every((s) => other.nfaStates.contains(s));
  }

  @override
  int get hashCode => nfaStates.map((s) => s.id).toList().toString().hashCode;
}

// DFA Transition class
class DFATransition {
  final DFAState from;
  final DFAState to;
  final String symbol;

  DFATransition(this.from, this.to, this.symbol);

  @override
  String toString() => '${from.toString()} --$symbol--> ${to.toString()}';
}

// DFA class
class DFA {
  final List<DFAState> states;
  final List<DFATransition> transitions;
  final DFAState startState;
  final List<DFAState> finalStates;
  final Set<String> alphabet;

  DFA({
    required this.states,
    required this.transitions,
    required this.startState,
    required this.finalStates,
    required this.alphabet,
  });

  // Get next state from current state on a symbol
  DFAState? getNextState(DFAState current, String symbol) {
    for (var transition in transitions) {
      if (transition.from.id == current.id && transition.symbol == symbol) {
        return transition.to;
      }
    }
    return null;
  }

  // Simulate string on DFA
  bool simulate(String input) {
    DFAState? current = startState;

    for (int i = 0; i < input.length; i++) {
      String symbol = input[i];
      current = getNextState(current!, symbol);
      if (current == null) return false;
    }

    return current != null && finalStates.any((s) => s.id == current!.id);
  }

  // Get simulation steps
  List<Map<String, String>> getSimulationSteps(String input) {
    List<Map<String, String>> steps = [];
    DFAState? current = startState;

    steps.add({
      'step': 'Start',
      'state': current.toString(),
      'symbol': '-',
      'nextState': current.toString(),
      'description': 'Starting at state ${current.toString()}',
    });

    for (int i = 0; i < input.length; i++) {
      String symbol = input[i];
      DFAState? next = getNextState(current!, symbol);

      if (next == null) {
        // If no transition, go to dead state (S8)
        final deadState =
            states.firstWhere((s) => s.id == 8, orElse: () => states.last);

        steps.add({
          'step': '${i + 1}',
          'state': current.toString(),
          'symbol': symbol,
          'nextState': deadState.toString(),
          'description':
              'No transition for "$symbol" → ${deadState.toString()}',
        });

        current = deadState;
        continue;
      }

      steps.add({
        'step': '${i + 1}',
        'state': current.toString(),
        'symbol': symbol,
        'nextState': next.toString(),
        'description': '${current.toString()} --$symbol--> ${next.toString()}',
      });

      current = next;
    }

    if (current != null && finalStates.contains(current)) {
      steps.add({
        'step': 'End',
        'state': current.toString(),
        'symbol': '-',
        'nextState': current.toString(),
        'description':
            '${current.toString()} is a Final State → String Accepted',
      });
    } else {
      steps.add({
        'step': 'End',
        'state': current?.toString() ?? 'None',
        'symbol': '-',
        'nextState': 'None',
        'description': 'Not in a final state → String Rejected',
      });
    }

    return steps;
  }

  // Get transition table
  Map<String, Map<String, String>> getTransitionTable() {
    Map<String, Map<String, String>> table = {};

    for (var state in states) {
      Map<String, String> stateTransitions = {};

      for (var symbol in alphabet) {
        DFAState? nextState = getNextState(state, symbol);
        stateTransitions[symbol] = nextState?.toString() ?? '-';
      }

      table[state.toString()] = stateTransitions;
    }

    return table;
  }
}
