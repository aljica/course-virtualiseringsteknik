#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

check() {
    local description=$1
    local command=$2
    local expected=$3

    result=$(eval "$command" 2>/dev/null)
    if echo "$result" | grep -q "$expected"; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $description"
        echo "  Expected: $expected"
        echo "  Got: $result"
        ((FAIL++))
    fi
}

echo "================================"
echo " Verifying lab environment..."
echo "================================"
echo ""

echo "--- Connectivity ---"
check "Control node reachable" "ansible control -m ping" "pong"
check "Webserver reachable" "ansible webserver -m ping" "pong"
check "Webserver2 reachable" "ansible webserver2 -m ping" "pong"
check "Database reachable" "ansible database -m ping" "pong"
check "Nginx reachable" "ansible nginx -m ping" "pong"

echo ""
echo "--- Flask Webserver 1 ---"
check "Flask / endpoint" "curl -s http://192.168.56.11:5000/" "Hello World"
check "Flask /secret endpoint" "curl -s http://192.168.56.11:5000/secret" "DB_USER"
check "Flask /visit endpoint" "curl -s http://192.168.56.11:5000/visit" "Server 1"

echo ""
echo "--- Flask Webserver 2 ---"
check "Flask / endpoint" "curl -s http://192.168.56.13:5000/" "Hello World"
check "Flask /secret endpoint" "curl -s http://192.168.56.13:5000/secret" "DB_USER"
check "Flask /visit endpoint" "curl -s http://192.168.56.13:5000/visit" "Server 2"

echo ""
echo "--- Nginx Load Balancer ---"
check "Nginx /visit - first request" "curl -s http://192.168.56.14/visit" "is serving this request"
check "Nginx /visit - second request" "curl -s http://192.168.56.14/visit" "is serving this request"

echo ""
echo "--- Database ---"
check "Visits table has entries" "ansible database -m shell -a 'sudo -u postgres psql -d coursedb -c \"SELECT COUNT(*) FROM visits;\"'" "row"

echo ""
echo "================================"
echo " Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo "================================"