import numpy as np
import pytest


@pytest.fixture
def small_X():
    """Tiny hand-made dataset shared by the unit tests."""
    return np.array([[1.0, 10.0],
                     [2.0, 20.0],
                     [3.0, 30.0]])
