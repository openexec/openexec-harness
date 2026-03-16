#!/bin/bash
# OpenExec Integration Harness
# Runs small scenarios to verify the implementation loop.

set -e

# Path to the local openexec binary
OPENEXEC_DIR="$(pwd)/../openexec"
OPENEXEC_BIN="$OPENEXEC_DIR/bin/openexec"
SCENARIOS_DIR="scenarios"

# 1. Validate environment and build if necessary
if [ "$1" == "--build" ]; then
    echo "🔨 Building OpenExec..."
    (cd "$OPENEXEC_DIR" && go build -o bin/openexec ./cmd/openexec)
    shift
fi

if [ ! -f "$OPENEXEC_BIN" ]; then
    echo "❌ OpenExec binary not found at $OPENEXEC_BIN"
    echo "   Run with --build to compile it first: ./run-harness.sh --build"
    exit 1
fi

# 2. Version Check
CURRENT_VER=$($OPENEXEC_BIN version | grep "OpenExec CLI" | awk '{print $3}')
SOURCE_VER=$(grep 'const Version =' "$OPENEXEC_DIR/pkg/version/version.go" | cut -d '"' -f 2)

echo "🔍 Version Check:"
echo "   Binary: $CURRENT_VER"
echo "   Source: v$SOURCE_VER"

if [ "$SOURCE_VER" != "${CURRENT_VER#v}" ]; then
    echo "⚠️ Warning: Binary version does not match source. Highly recommended to run with --build."
fi

function run_scenario() {
    local scenario_name=$1
    local scenario_path="$SCENARIOS_DIR/$scenario_name"
    
    echo "===================================================="
    echo "🚀 RUNNING SCENARIO: $scenario_name"
    echo "===================================================="
    
    if [ ! -d "$scenario_path" ]; then
        echo "❌ Scenario $scenario_name not found."
        return
    fi

    cd "$scenario_path"
    
    # 1. Clean up old state
    rm -rf .openexec
    
    # 2. Initialize project (non-interactive)
    echo "📌 Initializing..."
    $OPENEXEC_BIN init -y
    
    # 3. Plan the intent (skip validation for micro-scenarios)
    echo "📌 Planning..."
    $OPENEXEC_BIN plan INTENT.md --no-validate
    
    # 4. Start execution daemon
    echo "📌 Starting engine..."
    $OPENEXEC_BIN start --daemon
    
    # 5. Start execution
    echo "📌 Executing..."
    $OPENEXEC_BIN run
    
    # 6. Verify status
    echo "📌 Final Status:"
    $OPENEXEC_BIN status
    
    # 7. Stop daemon
    echo "📌 Stopping engine..."
    $OPENEXEC_BIN stop
    
    cd ../..
    echo "✅ Scenario $scenario_name complete."
    echo ""
}

# Run specific scenario or all
if [ -z "$1" ]; then
    run_scenario "01-smoke-web"
    run_scenario "02-broken-logic"
else
    run_scenario "$1"
fi

echo "🎉 All requested scenarios finished."
