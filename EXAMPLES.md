# Example Test Cases

## Valid Test Strings (Accepted)

### Pattern: gh*g + gmg
1. **gggmg** - matches gh*g (zero h's) + gmg
2. **ghggmg** - matches gh*g (one h) + gmg
3. **ghhggmg** - matches gh*g (two h's) + gmg
4. **ghhhggmg** - matches gh*g (three h's) + gmg

### Pattern: hm*h + gmg
5. **hhgmg** - matches hm*h (zero m's) + gmg
6. **hmhgmg** - matches hm*h (one m) + gmg
7. **hmmhgmg** - matches hm*h (two m's) + gmg

### Pattern: mg*m + gmg
8. **mmgmg** - matches mg*m (zero g's) + gmg
9. **mgmgmg** - matches mg*m (one g) + gmg
10. **mggmgmg** - matches mg*m (two g's) + gmg

## Invalid Test Strings (Rejected)

1. **ghg** - missing gmg suffix
2. **gmg** - doesn't match any of the three patterns
3. **hh** - incomplete pattern
4. **ghhmg** - incorrect suffix (missing g at end)
5. **mgm** - missing gmg suffix
6. **abc** - invalid symbols (not in alphabet {g, h, m})
7. **ghmg** - doesn't match pattern structure
8. **mhgmg** - first two symbols don't match any pattern
9. **ggggmg** - doesn't match pattern (too many g's without the required structure)
10. **hmgmg** - doesn't match pattern (missing final h before gmg)

## How the Pattern Works

The regular expression `(gh*g + hm*h + mg*m)gmg` consists of:

1. **Three alternatives (using +, which means OR)**:
   - `gh*g`: Start with 'g', followed by zero or more 'h's, followed by 'g'
   - `hm*h`: Start with 'h', followed by zero or more 'm's, followed by 'h'
   - `mg*m`: Start with 'm', followed by zero or more 'g's, followed by 'm'

2. **Followed by a fixed suffix**: `gmg`

## Testing in the App

1. Launch the app
2. The NFA, DFA, and Minimized DFA tables will be displayed automatically
3. Enter a test string in the input field
4. Click "Simulate" button
5. View the step-by-step simulation showing:
   - Current state
   - Input symbol being processed
   - Next state after transition
6. See the final result: **ACCEPTED** (green) or **REJECTED** (red)

## Understanding the Automata Tables

### NFA Table
- Shows all states including intermediate states
- Includes epsilon (ε) transitions
- Multiple transitions possible from a single state on the same symbol

### DFA Table
- Each state has exactly one transition per input symbol
- No epsilon transitions
- Deterministic - clear path for any input

### Minimized DFA Table
- Equivalent states merged together
- Smallest possible DFA that recognizes the same language
- Optimized for efficiency

## Simulation Steps Example

For input string "ghggmg":

```
Step Start: Starting at state D0
Step 1: D0 --g--> D1
Step 2: D1 --h--> D2
Step 3: D2 --g--> D3
Step 4: D3 --g--> D4
Step 5: D4 --m--> D5
Step 6: D5 --g--> D6
Step End: D6 is a Final State → String Accepted
```

Result: **ACCEPTED** ✓
