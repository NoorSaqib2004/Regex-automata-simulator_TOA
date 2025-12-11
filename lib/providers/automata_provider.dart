import 'package:flutter/material.dart';
import '../models/nfa.dart';
import '../models/dfa.dart';
import '../algorithms/thompson_construction.dart';
import '../algorithms/subset_construction.dart';
import '../algorithms/dfa_minimization.dart';

class AutomataProvider extends ChangeNotifier {
  NFA? _nfa;
  DFA? _dfa;
  DFA? _minimizedDFA;
  bool _isBuilt = false;

  NFA? get nfa => _nfa;
  DFA? get dfa => _dfa;
  DFA? get minimizedDFA => _minimizedDFA;
  bool get isBuilt => _isBuilt;

  void buildAutomata() {
    try {
      print('Building NFA...');
      ThompsonConstruction thompson = ThompsonConstruction();
      _nfa = thompson.buildNFA();
      print('NFA built with ${_nfa!.states.length} states');

      print('Converting to DFA...');
      SubsetConstruction subsetConstruction = SubsetConstruction();
      _dfa = subsetConstruction.convertNFAtoDFA(_nfa!);
      print('DFA built with ${_dfa!.states.length} states');

      print('Minimizing DFA...');
      DFAMinimization minimization = DFAMinimization();
      _minimizedDFA = minimization.minimize(_dfa!);
      print('Minimized DFA built with ${_minimizedDFA!.states.length} states');

      _isBuilt = true;
      print('Automata built successfully!');
      notifyListeners();
    } catch (e, stackTrace) {
      print('ERROR building automata: $e');
      print('Stack trace: $stackTrace');
    }
  }
}

class AutomataData {
  static final AutomataData _instance = AutomataData._internal();
  factory AutomataData() => _instance;
  AutomataData._internal();

  NFA? nfa;
  DFA? dfa;
  DFA? minimizedDFA;
  bool isBuilt = false;

  void buildAutomata() {
    try {
      print('Building NFA...');
      ThompsonConstruction thompson = ThompsonConstruction();
      nfa = thompson.buildNFA();
      print('NFA built with ${nfa!.states.length} states');

      print('Converting to DFA...');
      SubsetConstruction subsetConstruction = SubsetConstruction();
      dfa = subsetConstruction.convertNFAtoDFA(nfa!);
      print('DFA built with ${dfa!.states.length} states');

      print('Minimizing DFA...');
      DFAMinimization minimization = DFAMinimization();
      minimizedDFA = minimization.minimize(dfa!);
      print('Minimized DFA built with ${minimizedDFA!.states.length} states');

      isBuilt = true;
      print('Automata built successfully!');
    } catch (e, stackTrace) {
      print('ERROR building automata: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
