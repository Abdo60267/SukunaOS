# SukunaOS - Implementation Phase 1 Sprint 1-2 Build Guide

## 📦 Build Components

### 1. Malevolent Desktop Environment (MDE)

**Location**: `src/mde/`

**Build Requirements**:
```bash
sudo apt install -y libwayland-server-dev libwayland-client-dev wayland-protocols
```

**Build**:
```bash
cd src/mde
make
./mde-core
```

**Files**:
- `mde_core.c` - Main Wayland compositor
- `wm/window_manager.h` - Window manager interface
- `shell/panel.h` - Panel/taskbar interface

**Next Steps** (Sprint 1.2+):
- [ ] Implement weston backend integration
- [ ] Add input device handling (keyboard, mouse)
- [ ] Implement window manager (tiling layouts)
- [ ] Create panel and taskbar rendering
- [ ] Add application launcher
- [ ] Implement Sukuna visual theme (red/gold)
- [ ] Add multi-workspace support

---

### 2. King of Curses LSM (Kernel Security Module)

**Location**: `src/lsm/`

**Build Requirements**:
```bash
sudo apt install -y linux-headers-$(uname -r) build-essential

# On Debian/Ubuntu:
sudo apt install -y linux-image-$(uname -r)-dbg
```

**Build**:
```bash
cd src/lsm
make -C /lib/modules/$(uname -r)/build M=$(pwd) modules
```

**Files**:
- `king_of_curses.c` - LSM kernel module (5.7 KB)
- `cursectl.c` - Policy management CLI tool
- `Makefile` - Kernel module build
- `cursectl_build.mk` - cursectl build

**Install & Test**:
```bash
# Build cursectl
gcc -o cursectl cursectl.c

# Show status
./cursectl status

# Add policy
./cursectl policy add 1234 --sandbox --no-network

# Create domain
./cursectl domain create web-server
```

**Next Steps** (Sprint 1.3+):
- [ ] Implement /proc interface for policy management
- [ ] Add cgroups v2 integration
- [ ] Implement seccomp policy engine
- [ ] Add AppArmor profile support
- [ ] Create policy file format (.koc)
- [ ] Add audit logging
- [ ] Implement process domain tracking
- [ ] Add capability filtering

---

## 🔨 Master Build Script

Create `build_phase1.sh`:

```bash
#!/bin/bash
set -e

echo "=== SukunaOS Phase 1 Build ==="

# Build MDE
echo "[1/2] Building Malevolent Desktop Environment..."
cd src/mde
make clean
make
cd ../..

# Build LSM
echo "[2/2] Building King of Curses LSM..."
cd src/lsm
make clean
make -C /lib/modules/$(uname -r)/build M=$(pwd) modules
gcc -o cursectl cursectl.c
cd ../..

echo "=== Build Complete ==="
echo "✓ mde-core: src/mde/mde-core"
echo "✓ king_of_curses.ko: src/lsm/king_of_curses.ko"
echo "✓ cursectl: src/lsm/cursectl"
```

---

## 📊 Sprint Timeline (Weeks 1-4)

| Week | Component | Task | Status |
|------|-----------|------|--------|
| 1 | MDE | Core Wayland compositor template | ✅ DONE |
| 1 | LSM | Kernel module template + cursectl | ✅ DONE |
| 2 | MDE | Weston backend integration | 🔄 TODO |
| 2 | LSM | /proc interface + policy engine | 🔄 TODO |
| 3 | MDE | Window manager implementation | 🔄 TODO |
| 3 | LSM | cgroups + seccomp integration | 🔄 TODO |
| 4 | MDE | Panel/shell + theme application | 🔄 TODO |
| 4 | LSM | Audit logging + testing | 🔄 TODO |

---

## 📝 Code Organization

```
src/
├── mde/                          # Desktop Environment
│   ├── mde_core.c               # Main compositor
│   ├── Makefile                 # Build system
│   ├── wm/
│   │   ├── window_manager.h     # WM interface
│   │   └── window_manager.c     # WM implementation (TODO)
│   └── shell/
│       ├── panel.h              # Panel interface
│       ├── panel.c              # Panel impl (TODO)
│       ├── taskbar.c            # Taskbar (TODO)
│       └── launcher.c           # App launcher (TODO)
│
└── lsm/                          # Security Module
    ├── king_of_curses.c         # LSM kernel module
    ├── Makefile                 # Kernel module build
    ├── cursectl.c               # Policy tool
    ├── cursectl_build.mk        # cursectl build
    ├── koc_policy.h             # Policy structures (TODO)
    └── koc_domain.c             # Domain management (TODO)
```

---

## 🧪 Testing Checklist

### MDE Testing
- [ ] Compiles without warnings
- [ ] Wayland display socket created
- [ ] Compositor initializes
- [ ] No segfaults on startup
- [ ] Graceful shutdown on SIGTERM

### LSM Testing
- [ ] Module compiles for Linux 6.0+
- [ ] Module loads without errors
- [ ] cursectl shows status
- [ ] Policy rules can be added
- [ ] Domains can be created
- [ ] No kernel panics

---

## 🚀 Next Phase (Sprint 1.3+)

See `SUKUNAOS_MASTER_PLAN.md` for full roadmap.

**Target for next sprint**:
- MDE: weston integration + basic window rendering
- LSM: Full policy engine + cgroups integration

---

**Version**: 0.1.0-alpha  
**Date**: 2026-06-17  
**Status**: 🟢 Core templates ready, implementation starting
