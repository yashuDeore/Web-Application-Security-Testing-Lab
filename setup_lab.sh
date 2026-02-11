#!/bin/bash
# =============================================================
# VAPT Lab Auto-Setup Script
# Sets up DVWA and OWASP Juice Shop using Docker
# FOR EDUCATIONAL USE ONLY — Local Lab Environment
# =============================================================

set -e

echo "============================================"
echo "   VAPT Security Testing Lab Setup Script  "
echo "============================================"
echo ""

# Check Docker is installed
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker is not installed."
    echo "Install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi

echo "[+] Docker found: $(docker --version)"
echo ""

# ==========================================
# STEP 1: DVWA Setup
# ==========================================
echo "[*] Setting up DVWA (Damn Vulnerable Web Application)..."
echo "    URL will be: http://localhost:8080"

docker pull vulnerables/web-dvwa 2>/dev/null || echo "    Using cached DVWA image"

# Stop existing container if running
docker stop dvwa-lab 2>/dev/null || true
docker rm dvwa-lab 2>/dev/null || true

docker run -d \
    --name dvwa-lab \
    -p 8080:80 \
    vulnerables/web-dvwa

echo "[+] DVWA started at http://localhost:8080"
echo "    Default credentials: admin / password"
echo ""

# ==========================================
# STEP 2: OWASP Juice Shop Setup
# ==========================================
echo "[*] Setting up OWASP Juice Shop..."
echo "    URL will be: http://localhost:3000"

docker pull bkimminich/juice-shop 2>/dev/null || echo "    Using cached Juice Shop image"

# Stop existing container if running
docker stop juiceshop-lab 2>/dev/null || true
docker rm juiceshop-lab 2>/dev/null || true

docker run -d \
    --name juiceshop-lab \
    -p 3000:3000 \
    bkimminich/juice-shop

echo "[+] Juice Shop started at http://localhost:3000"
echo ""

# ==========================================
# STEP 3: Verify
# ==========================================
echo "[*] Waiting for services to start (15 seconds)..."
sleep 15

echo ""
echo "============================================"
echo "        Lab Setup Complete!"
echo "============================================"
echo ""
echo "  DVWA:        http://localhost:8080"
echo "               Login: admin / password"
echo "               Setup: Go to /setup.php first"
echo ""
echo "  Juice Shop:  http://localhost:3000"
echo "               Register any account to start"
echo ""
echo "  Burp Suite:  Configure proxy → 127.0.0.1:8080"
echo ""
echo "============================================"
echo ""
echo "[!] REMINDER: Only test in this local lab."
echo "    Never test on systems you don't own."
echo ""

# Show running containers
echo "[*] Running lab containers:"
docker ps --filter "name=dvwa-lab" --filter "name=juiceshop-lab" \
    --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
