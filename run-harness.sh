#!/bin/bash
# OpenExec Integration Harness
# Runs small scenarios to verify the implementation loop.

set -e

# Path to the local openexec binary
OPENEXEC_DIR="$(pwd)/../openexec"
OPENEXEC_BIN="$OPENEXEC_DIR/bin/openexec"
SCENARIOS_DIR="scenarios"

# Default configuration (can be overridden by flags)
PLANNER_MODEL="sonnet"
EXECUTOR_MODEL="sonnet"
REVIEWER_MODEL="opus"

function wait_for_engine() {
    local pid_file=".openexec/daemon.pid"
    local attempts=75
    local attempt
    local engine_port=""

    for ((attempt = 1; attempt <= attempts; attempt++)); do
        if [ -r "$pid_file" ]; then
            engine_port=$(cut -d: -f2 < "$pid_file")
            if [[ "$engine_port" =~ ^[0-9]+$ ]] && curl --fail --silent --show-error --max-time 1 \
                "http://127.0.0.1:${engine_port}/api/health" >/dev/null 2>&1; then
                echo "   ✓ Engine ready on port $engine_port"
                return 0
            fi
        fi
        sleep 0.2
    done

    echo "❌ Engine did not become ready within 15 seconds."
    if [ -r ".openexec/daemon.log" ]; then
        tail -n 20 ".openexec/daemon.log"
    fi
    return 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --build) BUILD=true ;;
        --planner) PLANNER_MODEL="$2"; shift ;;
        --executor) EXECUTOR_MODEL="$2"; shift ;;
        --reviewer) REVIEWER_MODEL="$2"; shift ;;
        --planner-cli) export OPENEXEC_PLANNER_CLI="$2"; shift ;;
        --executor-cli) export OPENEXEC_EXECUTOR_CLI="$2"; shift ;;
        *) SCENARIO_ARG="$1" ;;
    esac
    shift
done

# 1. Validate environment and build if necessary
if [ "$BUILD" == true ]; then
    echo "🔨 Building OpenExec..."
    (cd "$OPENEXEC_DIR" && go build -o bin/openexec ./cmd/openexec)
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
    echo "📌 Initializing with models: Planner=$PLANNER_MODEL, Executor=$EXECUTOR_MODEL, Reviewer=$REVIEWER_MODEL..."
    $OPENEXEC_BIN init -y --planner "$PLANNER_MODEL" --executor "$EXECUTOR_MODEL" --reviewer "$REVIEWER_MODEL"
    
    # 3. Plan the intent (skip validation for micro-scenarios)
    echo "📌 Planning..."
    $OPENEXEC_BIN plan INTENT.md --no-validate
    
    # 4. Start execution daemon
    echo "📌 Starting engine..."
    $OPENEXEC_BIN start --daemon
    wait_for_engine
    
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
if [ -z "$SCENARIO_ARG" ]; then
    run_scenario "01-smoke-web"
    run_scenario "02-broken-logic"
else
    run_scenario "$SCENARIO_ARG"
fi

echo "🎉 All requested scenarios finished."
