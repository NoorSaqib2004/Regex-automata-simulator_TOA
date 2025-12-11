# Quick Start Guide

## 🚀 Running the Application

### Option 1: Run on Chrome (Web)
```bash
flutter run -d chrome
```

### Option 2: Run on Windows Desktop
```bash
flutter run -d windows
```

### Option 3: Run on Edge Browser
```bash
flutter run -d edge
```

### Option 4: Let Flutter Choose
```bash
flutter run
```

---

## 📁 Project Structure

```
TOA_project/
├── lib/
│   ├── main.dart                          # Main UI and application entry
│   ├── models/
│   │   ├── nfa.dart                       # NFA classes (State, Transition, NFA)
│   │   └── dfa.dart                       # DFA classes (State, Transition, DFA)
│   └── algorithms/
│       ├── thompson_construction.dart     # Thompson's Construction for NFA
│       ├── subset_construction.dart       # NFA to DFA conversion
│       └── dfa_minimization.dart          # Hopcroft's Algorithm
├── pubspec.yaml                           # Flutter dependencies
├── README.md                              # Main documentation
├── EXAMPLES.md                            # Test cases and examples
├── ALGORITHMS.md                          # Detailed algorithm explanations
└── analysis_options.yaml                  # Dart analyzer settings
```

---

## 🎯 Features Checklist

✅ **Input Section**
- TextField for test string input
- Display of Regular Expression: `(gh*g + hm*h + mg*m)gmg`
- Simulate button

✅ **NFA Construction**
- Thompson's Construction algorithm
- Complete NFA transition table
- Start and final states marked
- Epsilon (ε) transitions displayed

✅ **DFA Construction**
- Subset Construction algorithm
- DFA transition table with all states
- Deterministic transitions (one per symbol)
- Start and final states clearly marked

✅ **DFA Minimization**
- Hopcroft's Algorithm implementation
- Minimized DFA transition table
- Reduced state count while preserving language

✅ **String Simulation**
- Step-by-step simulation display
- Each transition shown clearly (q0 --g--> q1)
- Final result: ACCEPTED (green) or REJECTED (red)
- Visual feedback with color coding

✅ **UI Components**
- Card widgets for organized sections
- DataTable for transition tables
- ListView for simulation steps
- Scrollable tables for large content
- Responsive layout

---

## 🧪 Testing the Application

### 1. Launch the App
Run one of the flutter run commands above.

### 2. View the Automata Tables
The app automatically displays:
- **NFA Transition Table**: Shows all NFA states and transitions
- **DFA Transition Table**: Shows the converted DFA
- **Minimized DFA Table**: Shows the optimized DFA

### 3. Test Some Strings

**Try these VALID strings** (should be ACCEPTED):
- `ggmg`
- `ghggmg`
- `ghhggmg`
- `hhgmg`
- `hmhgmg`
- `mmgmg`
- `mgmgmg`

**Try these INVALID strings** (should be REJECTED):
- `ghg`
- `gmg`
- `abc`
- `ghhmg`

### 4. Observe the Simulation
For each test string, you'll see:
1. Starting state
2. Each transition with input symbol
3. Next state after each symbol
4. Final result with color coding

---

## 📊 Understanding the Output

### NFA Table Format
| State | Symbol | Next State(s) |
|-------|--------|---------------|
| q0    | g      | q1            |
| q1    | h      | q1            |
| q1    | ε      | q2            |

- **ε**: Epsilon transition (no input consumed)
- Multiple entries for same state indicate non-determinism

### DFA Table Format
| State | g | h | m | Type |
|-------|---|---|---|------|
| D0    | D1| - | - | Start|
| D1    | D2| D3| - |      |
| D6    | - | - | - | Final|

- **Start**: Starting state
- **Final**: Accepting state
- **-**: No transition (reject)

### Simulation Steps
```
Step Start: Starting at state D0
Step 1: D0 --g--> D1
Step 2: D1 --h--> D2
...
Step End: D6 is a Final State → String Accepted
```

---

## 🔧 Troubleshooting

### Issue: "flutter: command not found"
**Solution**: Install Flutter SDK and add to PATH
```bash
# Check Flutter installation
flutter doctor
```

### Issue: No devices available
**Solution**: Run on web browser (Chrome or Edge)
```bash
flutter run -d chrome
```

### Issue: Build errors
**Solution**: Clean and rebuild
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📚 Additional Resources

- **README.md**: Project overview and features
- **ALGORITHMS.md**: Detailed algorithm explanations
- **EXAMPLES.md**: Test cases and pattern explanations

---

## 💡 Tips

1. **Scrolling**: Tables are horizontally scrollable if content is wide
2. **Testing**: Try different combinations of g, h, and m
3. **Understanding**: Read ALGORITHMS.md for deep dive into how it works
4. **Examples**: Check EXAMPLES.md for valid/invalid test cases

---

## 🎓 Learning Outcomes

After using this app, you'll understand:
- How regular expressions are converted to automata
- The difference between NFA and DFA
- How DFA minimization optimizes state machines
- Step-by-step string matching in finite automata
- Thompson's Construction algorithm
- Subset Construction algorithm
- Hopcroft's minimization algorithm

---

## ✨ Have Fun!

Experiment with different strings and observe how the automaton processes them step by step!
