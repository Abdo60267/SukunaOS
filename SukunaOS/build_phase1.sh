#!/bin/bash
#
# SukunaOS Phase 1 Build Script
# Builds MDE and King of Curses LSM
# 
# Usage: bash build_phase1.sh [clean]
#

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MDE_DIR="$REPO_ROOT/src/mde"
LSM_DIR="$REPO_ROOT/src/lsm"
KERNEL_VERSION=$(uname -r)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}╔════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║   SukunaOS Phase 1 Build System    ║${NC}"
echo -e "${YELLOW}║   MDE + King of Curses LSM         ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════╝${NC}\n"

# Check for clean flag
CLEAN_BUILD=${1:-""}

# Check dependencies
echo -e "${YELLOW}[*] Checking dependencies...${NC}"

if ! command -v gcc &> /dev/null; then
    echo -e "${RED}[!] gcc not found. Install with: sudo apt install build-essential${NC}"
    exit 1
fi

if ! pkg-config --exists wayland-server 2>/dev/null; then
    echo -e "${YELLOW}[!] wayland-server not found. Installing...${NC}"
    sudo apt update
    sudo apt install -y libwayland-server-dev libwayland-client-dev wayland-protocols
fi

echo -e "${GREEN}[✓] Dependencies OK${NC}\n"

# Build MDE
echo -e "${YELLOW}[1/2] Building Malevolent Desktop Environment...${NC}"
echo "      Location: $MDE_DIR"
echo "      Target: mde-core"

cd "$MDE_DIR"

if [ "$CLEAN_BUILD" = "clean" ]; then
    echo -e "${YELLOW}      Cleaning...${NC}"
    make clean 2>/dev/null || true
fi

if make 2>&1 | grep -q "error"; then
    echo -e "${RED}[!] MDE build FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}[✓] MDE build SUCCESS${NC}\n"
fi

# Build LSM kernel module
echo -e "${YELLOW}[2/3] Building King of Curses LSM...${NC}"
echo "      Location: $LSM_DIR"
echo "      Kernel: $KERNEL_VERSION"

cd "$LSM_DIR"

if [ "$CLEAN_BUILD" = "clean" ]; then
    echo -e "${YELLOW}      Cleaning...${NC}"
    make clean 2>/dev/null || true
fi

if make -C /lib/modules/$KERNEL_VERSION/build M=$(pwd) modules 2>&1 | grep -q "error"; then
    echo -e "${RED}[!] LSM build FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}[✓] LSM build SUCCESS${NC}\n"
fi

# Build cursectl
echo -e "${YELLOW}[3/3] Building cursectl (policy tool)...${NC}"

if gcc -o cursectl cursectl.c 2>&1 | grep -q "error"; then
    echo -e "${RED}[!] cursectl build FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}[✓] cursectl build SUCCESS${NC}\n"
fi

# Summary
echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Build Complete! 🎉               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}Artifacts:${NC}"
echo -e "  ${GREEN}✓${NC} $MDE_DIR/mde-core"
echo -e "  ${GREEN}✓${NC} $LSM_DIR/king_of_curses.ko"
echo -e "  ${GREEN}✓${NC} $LSM_DIR/cursectl"

echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "  1. Test MDE:  cd $MDE_DIR && ./mde-core"
echo -e "  2. Test LSM:  cd $LSM_DIR && ./cursectl status"
echo -e "  3. For kernel module: insmod king_of_curses.ko"

echo -e "\n${YELLOW}Documentation:${NC}"
echo -e "  - Build guide: $REPO_ROOT/PHASE1_BUILD_GUIDE.md"
echo -e "  - Master plan: $REPO_ROOT/SUKUNAOS_MASTER_PLAN.md"

exit 0
