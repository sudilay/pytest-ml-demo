#!/usr/bin/env bash
# Step-by-step demo: each Enter runs the next command.
# The original pipeline.py is ALWAYS restored on exit (even on errors or Ctrl-C).
set -u
cd "$(dirname "$0")"

PYTEST=".venv/bin/pytest"
[ -x "$PYTEST" ] || PYTEST="pytest"
PY=".venv/bin/python"
[ -x "$PY" ] || PY="python3"
SRC="src/pipeline.py"
BACKUP="src/pipeline.py.bak"

restore() {
  if [ -f "$BACKUP" ]; then
    mv "$BACKUP" "$SRC"
    echo -e "\n\033[32m[restored original $SRC]\033[0m"
  fi
}
trap restore EXIT
trap "exit 130" INT TERM

step() {
  echo -e "\n\033[1;36m━━ $1\033[0m"
  echo -e "\033[1;33m\$ $2\033[0m"
  read -r
  eval "$2"
}

clear
step "1. Unit tests: one function, isolated, fast" \
     "$PYTEST tests/unit -v"

step "2. Integration tests: the whole pipeline together, then its accuracy" \
     "$PYTEST -m integration -v; $PY $SRC"

step "3a. Introduce a bug: divide by max instead of std" \
     "cp $SRC $BACKUP && perl -pi -e 's|- mean\) / std|- mean) / np.asarray(X).max(axis=0)|' $SRC && diff $BACKUP $SRC"

if ! grep -q "max(axis=0)" "$SRC"; then
  echo "Bug was not applied, stopping."; exit 1
fi

step "3b. Integration tests again: does the pipeline notice?" \
     "$PYTEST -m integration -q; $PY $SRC"

step "3c. Unit tests again: does normalize() notice?" \
     "$PYTEST tests/unit -q --tb=short --show-capture=no -p no:warnings"

step "4. Fix the bug and run everything again" \
     "restore; $PYTEST -q"
