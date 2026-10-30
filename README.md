# Unit & Integration Testing with pytest: a tiny ML example

YZV 448E MLOps class presentation · Sude Dilay Tunç (150230716)

A small pipeline (`src/pipeline.py`): **load Iris → normalize (z-score) → train LogisticRegression → predict**

| Test type | File | What it checks |
|---|---|---|
| Unit | `tests/unit/test_normalize.py` | `fit_scaler` / `normalize` alone: mean 0, std 1, known values, constant column, empty input |
| Integration | `tests/integration/test_pipeline.py` | The whole pipeline: one valid label per sample, accuracy > 0.8 |

## Run
```bash
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
.venv/bin/pytest -v                 # everything
.venv/bin/pytest tests/unit         # only unit tests (fast)
.venv/bin/pytest -m integration     # only integration tests
.venv/bin/pytest --cov=src          # with coverage
./demo.sh                           # step-by-step class demo (press Enter)
```

## The demo's point
`demo.sh` injects a bug: `normalize` divides by **max** instead of **std**.
- Integration tests **still pass**: the model still reaches ~0.87 accuracy (it was 0.91). The bug is silent.
- Unit tests **fail** and show exactly which function is wrong and by how much.

That is why you need both: integration tests check that the parts fit together, unit tests check that each part is correct.
The original file is always restored when `demo.sh` exits (even after an error or Ctrl-C).
