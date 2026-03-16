# Intent: Fix Subtraction Bug

The `subtract` function in `calc.py` is currently behaving like `add`. We need to fix it and ensure all tests pass.

## Goals
- G-001: Correct the logic in `subtract`.
- G-002: Verify the fix using `pytest`.

## Requirements
- R-001: `subtract(a, b)` must return `a - b`.
- R-002: All tests in `test_calc.py` must pass.

## Constraints
- C-001: Only modify the `subtract` function in `calc.py`.
- C-002: Do not change the function signatures.

## Tasks
- T-001: Fix `calc.py` to use the `-` operator in `subtract`.
- T-002: Run `pytest test_calc.py` to verify all 3 tests pass.
