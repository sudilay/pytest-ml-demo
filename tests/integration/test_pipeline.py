"""Integration tests: check that load -> normalize -> train -> predict work TOGETHER."""
import numpy as np
import pytest

from pipeline import run_pipeline

pytestmark = pytest.mark.integration


def test_pipeline_returns_one_valid_label_per_sample():
    y_pred, y_test = run_pipeline()
    assert y_pred.shape == y_test.shape
    assert set(np.unique(y_pred)) <= {0, 1, 2}


def test_pipeline_beats_random_guessing():
    y_pred, y_test = run_pipeline()
    accuracy = (y_pred == y_test).mean()
    assert accuracy > 0.8  # random guessing on 3 classes = 0.33
