#!/bin/bash
# =============================================================
# HTTP Security Header Checker
# Checks for missing/misconfigured security headers
# FOR EDUCATIONAL USE IN AUTHORIZED LAB ENVIRONMENTS ONLY
# =============================================================

TARGET="${1:-http://localhost:8080}"

echo "========================================"
echo "   HTTP Security Header Checker"
echo "========================================"
echo "Target: $TARGET"
echo ""

# Fetch headers
HEADERS=$(curl -sk -I "$TARGET" 2>/dev/null)

if [ -z "$HEADERS" ]; then
    echo "[ERROR] Could not reach $TARGET"
    exit 1
fi

echo "[*] Raw Headers:"
echo "$HEADERS"
echo ""
echo "========================================"
echo "   Security Header Analysis"
echo "========================================"
echo ""

check_header() {
    local header_name="$1"
    local description="$2"
    local recommended="$3"

    if echo "$HEADERS" | grep -qi "^$header_name:"; then
        value=$(echo "$HEADERS" | grep -i "^$header_name:" | head -1)
        echo "[✅ PRESENT]  $header_name"
        echo "             Value: $value"
    else
        echo "[❌ MISSING]  $header_name"
        echo "             Risk: $description"
        echo "             Fix:  $recommended"
    fi
    echo ""
}

check_header \
    "Content-Security-Policy" \
    "No CSP allows XSS attacks and data injection" \
    "Content-Security-Policy: default-src 'self'"

check_header \
    "X-Frame-Options" \
    "Missing X-Frame-Options allows clickjacking attacks" \
    "X-Frame-Options: DENY"

check_header \
    "X-Content-Type-Options" \
    "Missing allows MIME sniffing attacks" \
    "X-Content-Type-Options: nosniff"

check_header \
    "Strict-Transport-Security" \
    "No HSTS allows protocol downgrade attacks" \
    "Strict-Transport-Security: max-age=31536000; includeSubDomains"

check_header \
    "Referrer-Policy" \
    "No referrer policy may leak sensitive URL information" \
    "Referrer-Policy: strict-origin-when-cross-origin"

check_header \
    "Permissions-Policy" \
    "Missing permissions policy allows full browser API access" \
    "Permissions-Policy: geolocation=(), microphone=(), camera=()"

# Check for info disclosure
echo "========================================"
echo "   Information Disclosure Check"
echo "========================================"
echo ""

if echo "$HEADERS" | grep -qi "^Server:"; then
    server=$(echo "$HEADERS" | grep -i "^Server:" | head -1)
    echo "[⚠️  WARNING]  Server version disclosed: $server"
    echo "             Fix: Set 'ServerTokens Prod' in Apache config"
else
    echo "[✅ OK]  Server header not exposing version"
fi
echo ""

if echo "$HEADERS" | grep -qi "^X-Powered-By:"; then
    powered=$(echo "$HEADERS" | grep -i "^X-Powered-By:" | head -1)
    echo "[⚠️  WARNING]  Technology stack disclosed: $powered"
    echo "             Fix: Remove X-Powered-By header"
else
    echo "[✅ OK]  X-Powered-By header not present"
fi

echo ""
echo "========================================"
echo "   Scan Complete"
echo "========================================"
