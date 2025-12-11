import '../models/nfa.dart';
import '../models/dfa.dart';

// Subset Construction Algorithm to convert NFA to DFA
class SubsetConstruction {
  DFA convertNFAtoDFA(NFA nfa) {
    List<DFAState> dfaStates = [];
    List<DFATransition> dfaTransitions = [];
    Map<String, DFAState> stateMap = {}; // Use String key instead
    List<Set<NFAState>> unmarkedStates = [];
    int dfaStateCounter = 0;

    // Helper function to create a unique key from a set of states
    String _getStateSetKey(Set<NFAState> states) {
      List<int> ids = states.map((s) => s.id).toList()..sort();
      return ids.join(',');
    }

    // Calculate epsilon closure of start state
    Set<NFAState> startClosure = nfa.epsilonClosure({nfa.startState});

    // Create DFA start state
    bool isStartFinal = startClosure.any((s) => nfa.finalStates.contains(s));
    DFAState dfaStart = DFAState(startClosure, dfaStateCounter++,
        isStart: true, isFinal: isStartFinal);

    dfaStates.add(dfaStart);
    stateMap[_getStateSetKey(startClosure)] = dfaStart;
    unmarkedStates.add(startClosure);

    // Process unmarked states
    while (unmarkedStates.isNotEmpty) {
      Set<NFAState> currentSet = unmarkedStates.removeLast();
      String currentKey = _getStateSetKey(currentSet);
      DFAState currentDFAState = stateMap[currentKey]!;

      // For each symbol in alphabet
      for (String symbol in nfa.alphabet) {
        // Calculate move and epsilon closure
        Set<NFAState> moveResult = nfa.move(currentSet, symbol);
        Set<NFAState> closure = nfa.epsilonClosure(moveResult);

        if (closure.isEmpty) continue;

        String closureKey = _getStateSetKey(closure);

        // Check if this state already exists
        DFAState? targetState = stateMap[closureKey];

        if (targetState == null) {
          // Create new DFA state
          bool isFinal = closure.any((s) => nfa.finalStates.contains(s));
          targetState = DFAState(closure, dfaStateCounter++, isFinal: isFinal);

          dfaStates.add(targetState);
          stateMap[closureKey] = targetState;
          unmarkedStates.add(closure);
        }

        // Add transition
        dfaTransitions.add(DFATransition(currentDFAState, targetState, symbol));
      }
    }

    // Collect final states
    List<DFAState> finalStates = dfaStates.where((s) => s.isFinal).toList();

    return DFA(
      states: dfaStates,
      transitions: dfaTransitions,
      startState: dfaStart,
      finalStates: finalStates,
      alphabet: nfa.alphabet,
    );
  }
}
