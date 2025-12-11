import '../models/dfa.dart';

// DFA Minimization using Hopcroft's Algorithm (simplified version)
class DFAMinimization {
  DFA minimize(DFA dfa) {
    // Step 1: Initial partition into final and non-final states
    Set<DFAState> finalStates = Set.from(dfa.finalStates);
    Set<DFAState> nonFinalStates = dfa.states.where((s) => !s.isFinal).toSet();

    List<Set<DFAState>> partitions = [];
    if (nonFinalStates.isNotEmpty) partitions.add(nonFinalStates);
    if (finalStates.isNotEmpty) partitions.add(finalStates);

    // Step 2: Refine partitions
    bool changed = true;
    while (changed) {
      changed = false;
      List<Set<DFAState>> newPartitions = [];

      for (var partition in partitions) {
        if (partition.length <= 1) {
          newPartitions.add(partition);
          continue;
        }

        // Try to split this partition
        Map<String, Set<DFAState>> splits = {};

        for (var state in partition) {
          // Create signature based on transitions
          String signature = '';
          for (var symbol in dfa.alphabet.toList()..sort()) {
            DFAState? nextState = dfa.getNextState(state, symbol);

            // Find which partition the next state belongs to
            int partitionIndex = -1;
            for (int i = 0; i < partitions.length; i++) {
              if (nextState != null && partitions[i].contains(nextState)) {
                partitionIndex = i;
                break;
              }
            }

            signature += '$symbol:$partitionIndex,';
          }

          if (!splits.containsKey(signature)) {
            splits[signature] = {};
          }
          splits[signature]!.add(state);
        }

        // If we split the partition, mark as changed
        if (splits.length > 1) {
          changed = true;
        }

        newPartitions.addAll(splits.values);
      }

      partitions = newPartitions;
    }

    // Step 3: Build minimized DFA
    Map<DFAState, DFAState> stateToMinState = {};
    List<DFAState> minStates = [];
    int minStateCounter = 0;

    for (var partition in partitions) {
      // Pick representative state
      DFAState representative = partition.first;
      bool isFinal = partition.any((s) => s.isFinal);
      bool isStart = partition.contains(dfa.startState);

      DFAState minState = DFAState(
        representative.nfaStates,
        minStateCounter++,
        isStart: isStart,
        isFinal: isFinal,
      );

      minStates.add(minState);

      // Map all states in partition to this min state
      for (var state in partition) {
        stateToMinState[state] = minState;
      }
    }

    // Build transitions for minimized DFA
    List<DFATransition> minTransitions = [];
    Set<String> addedTransitions = {};

    for (var transition in dfa.transitions) {
      DFAState minFrom = stateToMinState[transition.from]!;
      DFAState minTo = stateToMinState[transition.to]!;

      String transKey = '${minFrom.id}-${transition.symbol}-${minTo.id}';
      if (!addedTransitions.contains(transKey)) {
        minTransitions.add(DFATransition(minFrom, minTo, transition.symbol));
        addedTransitions.add(transKey);
      }
    }

    DFAState minStartState = stateToMinState[dfa.startState]!;
    List<DFAState> minFinalStates = minStates.where((s) => s.isFinal).toList();

    return DFA(
      states: minStates,
      transitions: minTransitions,
      startState: minStartState,
      finalStates: minFinalStates,
      alphabet: dfa.alphabet,
    );
  }
}
