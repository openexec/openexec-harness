#!/bin/bash
# =============================================================================
# T-US-001-001: Footer Element Test Suite
# =============================================================================
# BDD-Style Acceptance Tests for Contact Footer Implementation
#
# Contract Under Test:
#   GIVEN the index.html file
#   WHEN parsed as valid HTML
#   THEN:
#     - A single <footer> element exists with id="contact"
#     - The footer contains text "Contact:"
#     - The footer contains an <a> element with href="mailto:hello@openexec.io"
#     - The <a> element text content is "hello@openexec.io"
#     - The footer appears before </body>
# =============================================================================

set -uo pipefail
# Note: Not using -e because grep returns non-zero when no match, which is expected behavior

# Navigate to project root (parent of tests directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Test counters
PASS_COUNT=0
FAIL_COUNT=0
TOTAL_TESTS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Test result functions
pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASS_COUNT++))
    ((TOTAL_TESTS++))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAIL_COUNT++))
    ((TOTAL_TESTS++))
}

describe() {
    echo ""
    echo -e "${YELLOW}▸ $1${NC}"
}

# =============================================================================
# Test Suite
# =============================================================================

echo "=============================================="
echo "  T-US-001-001: Footer Element Test Suite"
echo "=============================================="
echo "  Target: index.html"
echo "  Contract: HTML Structure Contract"
echo "=============================================="

# Prerequisite check
if [ ! -f "index.html" ]; then
    echo -e "${RED}ERROR: index.html not found in $PROJECT_ROOT${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
describe "Feature: Footer Element Presence"
# -----------------------------------------------------------------------------

# TS-001: Footer element with correct ID
if grep -q '<footer id="contact">' index.html; then
    pass "TS-001: Footer element exists with id='contact'"
else
    fail "TS-001: Footer element with id='contact' not found"
fi

# -----------------------------------------------------------------------------
describe "Feature: Contact Information Content"
# -----------------------------------------------------------------------------

# TS-002: Contact email address present
if grep -q 'hello@openexec.io' index.html; then
    pass "TS-002: Contact email 'hello@openexec.io' is present"
else
    fail "TS-002: Contact email 'hello@openexec.io' not found"
fi

# TS-003: mailto link for accessibility
if grep -q 'href="mailto:hello@openexec.io"' index.html; then
    pass "TS-003: mailto link exists for accessibility"
else
    fail "TS-003: mailto link not found (accessibility requirement)"
fi

# TS-004: Contact label prefix
if grep -q 'Contact:' index.html; then
    pass "TS-004: 'Contact:' label prefix present"
else
    fail "TS-004: 'Contact:' label prefix not found"
fi

# -----------------------------------------------------------------------------
describe "Feature: HTML Structure Integrity"
# -----------------------------------------------------------------------------

# EC-001: Single footer element (no duplicates)
FOOTER_COUNT=$(grep -c '<footer' index.html || true)
if [ "$FOOTER_COUNT" -eq 1 ]; then
    pass "EC-001: Exactly one footer element (no duplicates)"
else
    fail "EC-001: Expected 1 footer, found $FOOTER_COUNT"
fi

# EC-002: Unique ID constraint
CONTACT_ID_COUNT=$(grep -c 'id="contact"' index.html || true)
if [ "$CONTACT_ID_COUNT" -eq 1 ]; then
    pass "EC-002: id='contact' is unique in document"
else
    fail "EC-002: id='contact' is not unique (found $CONTACT_ID_COUNT times)"
fi

# EC-003: Properly closed footer tag
if grep -q '</footer>' index.html; then
    pass "EC-003: Footer element is properly closed"
else
    fail "EC-003: Missing </footer> closing tag"
fi

# EC-004: Footer appears before </body>
# Check that footer comes before body close
FOOTER_LINE=$(grep -n '<footer' index.html | head -1 | cut -d: -f1)
BODY_CLOSE_LINE=$(grep -n '</body>' index.html | head -1 | cut -d: -f1)
if [ -n "$FOOTER_LINE" ] && [ -n "$BODY_CLOSE_LINE" ] && [ "$FOOTER_LINE" -lt "$BODY_CLOSE_LINE" ]; then
    pass "EC-004: Footer appears before </body> (line $FOOTER_LINE < $BODY_CLOSE_LINE)"
else
    fail "EC-004: Footer must appear before </body>"
fi

# =============================================================================
# Summary
# =============================================================================

echo ""
echo "=============================================="
echo "  Test Summary"
echo "=============================================="
echo "  Total:  $TOTAL_TESTS"
echo -e "  ${GREEN}Passed${NC}: $PASS_COUNT"
echo -e "  ${RED}Failed${NC}: $FAIL_COUNT"
echo "=============================================="

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo -e "${RED}RESULT: FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}RESULT: ALL TESTS PASSED${NC}"
    exit 0
fi
