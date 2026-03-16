# OpenExec Integration Harness (Smoke Scenarios)

This project contains minimal, fast-feedback integration tests for **OpenExec**. It is designed to verify the core orchestration loop, context assembly, and blueprint execution in under 60 seconds per scenario.

## Scenarios

1.  **`01-smoke-web`**: Verifies basic HTML file modification and CSS injection.
2.  **`02-broken-logic`**: Verifies agentic debugging. Fixes a Python subtraction bug and runs `pytest` to confirm success.

## Usage

The harness can automatically build and verify the OpenExec version before running scenarios.

**Run all scenarios with auto-build:**
```bash
./run-harness.sh --build
```

**Run all scenarios using existing binary (with version check):**
```bash
./run-harness.sh
```

**Run a single scenario:**
```bash
./run-harness.sh 01-smoke-web
```

## Why use this?
*   **Version Integrity**: Automatically warns if your testing binary is out of sync with your source code.
*   **Prevent 80% Plateaus**: Ensures that code changes aren't just "scaffolded" but actually implemented.
*   **Fast Iteration**: Test prompt and blueprint changes in seconds, not minutes.
*   **Deterministic Control**: Uses the local OpenExec binary to prove that core fixes (permissions, task descriptions) work in practice.
