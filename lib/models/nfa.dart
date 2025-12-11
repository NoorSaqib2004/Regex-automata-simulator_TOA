// NFA State class
class NFAState {
  final int id;
  bool isStart;
  bool isFinal;

  NFAState(this.id, {this.isStart = false, this.isFinal = false});

  @override
  String toString() => 'q$id';
}

// NFA Transition class
class NFATransition {
  final NFAState from;
  final NFAState to;
  final String symbol; // 'ε' for epsilon transitions

  NFATransition(this.from, this.to, this.symbol);

  @override
  String toString() => '${from.toString()} --$symbol--> ${to.toString()}';
}

// NFA class
class NFA {
  final List<NFAState> states;
  final List<NFATransition> transitions;
  final NFAState startState;
  final List<NFAState> finalStates;
  final Set<String> alphabet;

  NFA({
    required this.states,
    required this.transitions,
    required this.startState,
    required this.finalStates,
    required this.alphabet,
  });

  // Get epsilon closure of a set of states
  Set<NFAState> epsilonClosure(Set<NFAState> states) {
    Set<NFAState> closure = Set.from(states);
    List<NFAState> stack = List.from(states);

    while (stack.isNotEmpty) {
      NFAState current = stack.removeLast();

      for (var transition in transitions) {
        if (transition.from == current && transition.symbol == 'ε') {
          if (!closure.contains(transition.to)) {
            closure.add(transition.to);
            stack.add(transition.to);
          }
        }
      }
    }

    return closure;
  }

  // Get states reachable from a set of states on a symbol
  Set<NFAState> move(Set<NFAState> states, String symbol) {
    Set<NFAState> result = {};

    for (var state in states) {
      for (var transition in transitions) {
        if (transition.from == state && transition.symbol == symbol) {
          result.add(transition.to);
        }
      }
    }

    return result;
  }

  // Get transition table as a map
  Map<String, List<Map<String, dynamic>>> getTransitionTable() {
    Map<String, List<Map<String, dynamic>>> table = {};

    for (var state in states) {
      List<Map<String, dynamic>> stateTransitions = [];

      // Group transitions by symbol
      Map<String, List<String>> transitionsBySymbol = {};
      for (var transition in transitions) {
        if (transition.from == state) {
          if (!transitionsBySymbol.containsKey(transition.symbol)) {
            transitionsBySymbol[transition.symbol] = [];
          }
          transitionsBySymbol[transition.symbol]!.add(transition.to.toString());
        }
      }

      for (var symbol in transitionsBySymbol.keys) {
        stateTransitions.add({
          'symbol': symbol,
          'to': transitionsBySymbol[symbol]!.join(', '),
        });
      }

      table[state.toString()] = stateTransitions;
    }

    return table;
  }
}
