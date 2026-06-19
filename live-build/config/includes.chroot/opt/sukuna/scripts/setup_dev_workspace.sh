#!/usr/bin/env bash
set -euo pipefail

# scripts/setup_dev_workspace.sh
# Creates a developer workspace with example projects for Sukuna Dev Kit.

WORKDIR=${1:-$HOME/sukuna-dev}

echo "Creating Sukuna developer workspace in $WORKDIR"
mkdir -p "$WORKDIR"

cp -r devkit/templates/c_cpp "$WORKDIR/c_cpp_example"
cp -r devkit/templates/python "$WORKDIR/python_example"
cp -r devkit/templates/java "$WORKDIR/java_example"
cp -r devkit/templates/csharp "$WORKDIR/csharp_example"
cp -r devkit/templates/rust "$WORKDIR/rust_example"
cp -r devkit/templates/go "$WORKDIR/go_example"
cp -r devkit/templates/node "$WORKDIR/node_example"

cat > "$WORKDIR/README.md" <<'EOF'
# SukunaOS Dev Workspace

This workspace contains example starter projects for the Sukuna Dev Kit.

Examples:
- C: `c_cpp_example/hello.c`
- Python: `python_example/hello.py`
- Java: `java_example/Hello.java`
- C#: `csharp_example/Program.cs`
- Rust: `rust_example`
- Go: `go_example/hello.go`
- Node.js: `node_example/index.js`

Build examples:
- C: `gcc hello.c -o hello && ./hello`
- Python: `python3 hello.py`
- Java: `javac Hello.java && java Hello`
- C#: `dotnet new console --output . --force && dotnet run`
- Rust: `cargo run`
- Go: `go run hello.go`
- Node: `node index.js`
EOF

echo "Developer workspace ready. See $WORKDIR/README.md"
