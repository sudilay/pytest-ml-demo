#!/usr/bin/env bash
# Step-by-step demo: press Enter to run each command.
# The original pipeline.py is ALWAYS restored on exit (even on errors or Ctrl-C).
set -u
cd "$(dirname "$0")"

PYTEST=".venv/bin/pytest"
[ -x "$PYTEST" ] || PYTEST="pytest"
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
  read -r -p "  (press Enter) "
  eval "$2"
}

clear
step "1. How the tests are organized, the function we test, and its unit test" \
     "find tests -name '*.py' | sort; echo '────────'; sed -n '13,26p' $SRC; echo '────────'; sed -n '8,17p' tests/unit/test_normalize.py"

step "2. Unit tests: one function, isolated, fast" \
     "$PYTEST tests/unit -v"

step "3. Integration tests: the whole pipeline together" \
     "$PYTEST -m integration -v"

step "4a. Introduce a bug: divide by max instead of std" \
     "cp $SRC $BACKUP && perl -pi -e 's|- mean\) / std|- mean) / np.asarray(X).max(axis=0)|' $SRC && diff $BACKUP $SRC"

if ! grep -q "max(axis=0)" "$SRC"; then
  echo "Bug was not applied, stopping."; exit 1
fi

step "4b. Run the integration tests: does the pipeline notice?" \
     "$PYTEST -m integration -q"

step "4c. Run the unit tests: does normalize() notice?" \
     "$PYTEST tests/unit -q --tb=short --show-capture=no -p no:warnings"

step "5. Fix the bug and run everything again" \
     "restore; $PYTEST -q"
