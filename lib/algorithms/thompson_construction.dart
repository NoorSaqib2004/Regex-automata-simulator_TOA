import '../models/nfa.dart';

// Thompson's Construction for the specific RE: (gh*g + hm*h + mg*m)gmg
class ThompsonConstruction {
  int stateCounter = 0;

  NFAState createState({bool isStart = false, bool isFinal = false}) {
    return NFAState(stateCounter++, isStart: isStart, isFinal: isFinal);
  }

  // Build NFA for the given regular expression: (gh*g + hm*h + mg*m)gmg
  NFA buildNFA() {
    List<NFAState> states = [];
    List<NFATransition> transitions = [];
    Set<String> alphabet = {'g', 'h', 'm'};

    // Create all 31 states (q0 to q30)
    for (int i = 0; i <= 30; i++) {
      states.add(NFAState(i, isStart: i == 0, isFinal: i == 30));
    }

    // Build transitions based on the provided transition table
    void addTrans(int from, int to, String symbol) {
      transitions.add(NFATransition(states[from], states[to], symbol));
    }

    // q0 -> q1, q2 (epsilon)
    addTrans(0, 1, 'ε');
    addTrans(0, 2, 'ε');

    // q1 -> q3, q4 (epsilon)
    addTrans(1, 3, 'ε');
    addTrans(1, 4, 'ε');

    // q2 -> q5 (m)
    addTrans(2, 5, 'm');

    // q3 -> q6 (g)
    addTrans(3, 6, 'g');

    // q4 -> q7 (h)
    addTrans(4, 7, 'h');

    // q5 -> q8 (epsilon)
    addTrans(5, 8, 'ε');

    // q6 -> q9 (epsilon)
    addTrans(6, 9, 'ε');

    // q7 -> q10 (epsilon)
    addTrans(7, 10, 'ε');

    // q8 -> q11, q12 (epsilon)
    addTrans(8, 11, 'ε');
    addTrans(8, 12, 'ε');

    // q9 -> q13, q14 (epsilon)
    addTrans(9, 13, 'ε');
    addTrans(9, 14, 'ε');

    // q10 -> q15, q16 (epsilon)
    addTrans(10, 15, 'ε');
    addTrans(10, 16, 'ε');

    // q11 -> q17 (g)
    addTrans(11, 17, 'g');

    // q12 -> q18 (m)
    addTrans(12, 18, 'm');

    // q13 -> q19 (h)
    addTrans(13, 19, 'h');

    // q14 -> q20 (g)
    addTrans(14, 20, 'g');

    // q15 -> q21 (m)
    addTrans(15, 21, 'm');

    // q16 -> q22 (h)
    addTrans(16, 22, 'h');

    // q17 -> q11, q12 (epsilon)
    addTrans(17, 11, 'ε');
    addTrans(17, 12, 'ε');

    // q18 -> q23 (epsilon)
    addTrans(18, 23, 'ε');

    // q19 -> q13, q14 (epsilon)
    addTrans(19, 13, 'ε');
    addTrans(19, 14, 'ε');

    // q20 -> q24 (epsilon)
    addTrans(20, 24, 'ε');

    // q21 -> q15, q16 (epsilon)
    addTrans(21, 15, 'ε');
    addTrans(21, 16, 'ε');

    // q22 -> q24 (epsilon)
    addTrans(22, 24, 'ε');

    // q23 -> q25 (epsilon)
    addTrans(23, 25, 'ε');

    // q24 -> q23 (epsilon)
    addTrans(24, 23, 'ε');

    // q25 -> q26 (g)
    addTrans(25, 26, 'g');

    // q26 -> q27 (epsilon)
    addTrans(26, 27, 'ε');

    // q27 -> q28 (m)
    addTrans(27, 28, 'm');

    // q28 -> q29 (epsilon)
    addTrans(28, 29, 'ε');

    // q29 -> q30 (g)
    addTrans(29, 30, 'g');

    return NFA(
      states: states,
      transitions: transitions,
      startState: states[0],
      finalStates: [states[30]],
      alphabet: alphabet,
    );
  }
}
