# Algorithm Explanations

## 1. Thompson's Construction Algorithm

### Purpose
Converts a regular expression into a Non-deterministic Finite Automaton (NFA).

### How It Works for `(gh*g + hm*h + mg*m)gmg`

#### Step 1: Build Individual Components

**Branch 1: gh*g**
- Create states for: g → h* → g
- h* means zero or more h's (implemented with a loop and epsilon transition)
- States: q0 --g--> q1 --h--> q1 (loop) --ε--> q2 --g--> q3

**Branch 2: hm*h**
- Create states for: h → m* → h
- m* means zero or more m's (loop with epsilon transition)
- States: q4 --h--> q5 --m--> q5 (loop) --ε--> q6 --h--> q7

**Branch 3: mg*m**
- Create states for: m → g* → m
- g* means zero or more g's (loop with epsilon transition)
- States: q8 --m--> q9 --g--> q9 (loop) --ε--> q10 --m--> q11

#### Step 2: Combine Branches with Union (+)
- Create a start state with epsilon transitions to each branch
- Merge end states of all branches into one state
- This implements the OR operation (union)

#### Step 3: Add Suffix 'gmg'
- From merged state: --g--> --m--> --g--> (final state)

### Key Features
- **Epsilon (ε) transitions**: Allow state changes without consuming input
- **Star operator (*)**: Implemented with a loop back to the same state
- **Union (+)**: Implemented with epsilon transitions from start to each option

---

## 2. Subset Construction Algorithm

### Purpose
Converts an NFA into a Deterministic Finite Automaton (DFA).

### Algorithm Steps

#### 1. Epsilon Closure
- For any set of NFA states, find all states reachable via epsilon transitions
- Example: If state q0 has ε-transitions to q1 and q2, then ε-closure({q0}) = {q0, q1, q2}

#### 2. Initial DFA State
- Start with ε-closure of the NFA start state
- This becomes the DFA start state

#### 3. Process Each DFA State
For each unmarked DFA state and each input symbol:
1. Find all NFA states reachable via that symbol (move operation)
2. Take epsilon closure of those states
3. This becomes a new DFA state (or maps to an existing one)
4. Add a transition in the DFA

#### 4. Mark Final States
- A DFA state is final if it contains any NFA final state

### Example Transformation
```
NFA states {q0, q1, q2} on input 'g' → NFA states {q3, q4}
ε-closure({q3, q4}) → {q3, q4, q5}
This becomes DFA state D1
Transition: D0 --g--> D1
```

### Result
- No epsilon transitions in DFA
- Exactly one transition per symbol per state
- May have more states than NFA (worst case: 2^n states)

---

## 3. Hopcroft's Algorithm (DFA Minimization)

### Purpose
Minimize the DFA by merging equivalent states while preserving the language.

### Algorithm Steps

#### 1. Initial Partition
- Divide states into two groups:
  - Final states
  - Non-final states

#### 2. Refine Partitions
Repeatedly split partitions based on transition behavior:
- Two states are equivalent if:
  1. Both are final or both are non-final
  2. For each input symbol, they transition to states in the same partition

#### 3. Split Process
For each partition P and each input symbol a:
- If states in P transition to different partitions on symbol a
- Split P into sub-partitions

#### 4. Repeat Until Stable
- Continue splitting until no more partitions can be split
- This is the minimal partition

#### 5. Build Minimized DFA
- Each partition becomes one state in the minimized DFA
- Map transitions between partitions

### Example

**Before Minimization:**
```
States: D0, D1, D2, D3, D4
D1 and D2 always transition to the same states
D3 and D4 always transition to the same states
```

**After Minimization:**
```
States: D0, D1', D2' (where D1' = {D1, D2}, D2' = {D3, D4})
```

### Benefits
- Reduces number of states
- Maintains language recognition
- Optimal (produces the minimal DFA)
- Time complexity: O(n log n) where n is number of states

---

## 4. String Simulation Algorithm

### Purpose
Test whether an input string is accepted by the DFA.

### Algorithm Steps

#### 1. Initialize
- Start at the DFA start state
- Read input string from left to right

#### 2. Process Each Symbol
For each symbol in the input:
1. Look up the transition from current state on this symbol
2. If no transition exists → **REJECT**
3. If transition exists → move to the next state

#### 3. Check Final State
After processing all symbols:
- If current state is a final state → **ACCEPT**
- Otherwise → **REJECT**

### Step-by-Step Example
Input: "ghggmg" on minimized DFA

```
Initial: State D0 (start)
Read 'g': D0 --g--> D1
Read 'h': D1 --h--> D2
Read 'g': D2 --g--> D3
Read 'g': D3 --g--> D4
Read 'm': D4 --m--> D5
Read 'g': D5 --g--> D6
End: D6 is final → ACCEPT ✓
```

### Time Complexity
- O(n) where n is the length of the input string
- Each symbol requires one state lookup

---

## Comparison of Automata Types

| Feature | NFA | DFA | Minimized DFA |
|---------|-----|-----|---------------|
| **Epsilon transitions** | Yes | No | No |
| **Deterministic** | No | Yes | Yes |
| **States** | Fewer | More | Minimal |
| **Construction** | Easier | Complex | Most complex |
| **Simulation** | Slower | Fast | Fast |
| **Memory** | Less | More | Least |
| **Practical use** | Theory | Implementation | Optimized implementation |

---

## Regular Expression Components

### Symbols
- **g, h, m**: Terminal symbols (alphabet)
- **ε (epsilon)**: Empty string (no input consumed)

### Operators
- **\*** (Kleene star): Zero or more repetitions
  - h* means: ε, h, hh, hhh, ...
- **+** (Union): OR operation
  - a + b means: a or b
- **Concatenation**: Sequence
  - ab means: a followed by b

### Precedence (Highest to Lowest)
1. Kleene star (*)
2. Concatenation
3. Union (+)

### Example Breakdown: `(gh*g + hm*h + mg*m)gmg`
1. **Parentheses**: Group the union
2. **Star**: h*, m*, g* evaluated first
3. **Concatenation**: gh*g, hm*h, mg*m formed
4. **Union**: Three alternatives combined
5. **Final concatenation**: Result followed by gmg
