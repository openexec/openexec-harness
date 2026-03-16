#!/bin/bash
# T-US-001-001 Verification Tests
# Tests footer element implementation

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Helper functions
pass() { echo "✓ PASS: $1"; ((PASS_COUNT++)); }
fail() { echo "✗ FAIL: $1"; ((FAIL_COUNT++)); }
warn() { echo "⚠ WARN: $1"; ((WARN_COUNT++)); }

echo "=== T-US-001-001 Footer Verification ==="
echo ""

# TS-001: Footer element exists with id="contact"
if grep -q '<footer id="contact">' index.html; then
    pass "TS-001: Footer element with id='contact' exists"
else
    fail "TS-001: Footer element with id='contact' missing"
fi

# TS-002: Contact email present
if grep -q 'hello@openexec.io' index.html; then
    pass "TS-002: Contact email present"
else
    fail "TS-002: Contact email missing"
fi

# TS-003: Email is clickable (mailto link)
if grep -q 'mailto:hello@openexec.io' index.html; then
    pass "TS-003: Email is clickable (mailto link)"
else
    fail "TS-003: Email not clickable (mailto link missing)"
fi

# TS-004: Contact label present
if grep -q 'Contact:' index.html; then
    pass "TS-004: Contact label present"
else
    fail "TS-004: Contact label missing"
fi

# EC-001: Edge case - Multiple footers check
FOOTER_COUNT=$(grep -c '<footer' index.html || true)
if [ "$FOOTER_COUNT" -eq 1 ]; then
    pass "EC-001: Single footer element (no duplicates)"
elif [ "$FOOTER_COUNT" -eq 0 ]; then
    fail "EC-001: No footer element found"
else
    fail "EC-001: Multiple footer elements found ($FOOTER_COUNT)"
fi

# EC-002: Edge case - Unique ID check
CONTACT_ID_COUNT=$(grep -c 'id="contact"' index.html || true)
if [ "$CONTACT_ID_COUNT" -eq 1 ]; then
    pass "EC-002: id='contact' is unique"
elif [ "$CONTACT_ID_COUNT" -eq 0 ]; then
    fail "EC-002: id='contact' not found"
else
    fail "EC-002: Duplicate id='contact' found ($CONTACT_ID_COUNT times)"
fi

# EC-003: Edge case - Footer closing tag check
if grep -q '</footer>' index.html; then
    pass "EC-003: Footer properly closed"
else
    fail "EC-003: Footer closing tag missing"
fi

echo ""
echo "=== Summary ==="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "Warnings: $WARN_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RESULT: FAILED"
    exit 1
else
    echo "RESULT: PASSED"
    exit 0
fi
