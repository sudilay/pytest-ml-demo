"""Unit tests: check ONE function (normalize) in isolation, in milliseconds."""
import numpy as np
import pytest

from pipeline import fit_scaler, normalize


def test_normalized_columns_have_mean_0_and_std_1(small_X):
    # Arrange
    mean, std = fit_scaler(small_X)
    # Act
    Z = normalize(small_X, mean, std)
    # Assert
    assert Z.mean(axis=0) == pytest.approx([0.0, 0.0])
    assert Z.std(axis=0) == pytest.approx([1.0, 1.0])


@pytest.mark.parametrize(
    "value, expected",
    [
        (0.0, -1.0),   # left end
        (2.5, -0.5),   # between the left end and the mean
        (10.0, 1.0),   # right end
    ],
)
def test_known_values(value, expected):
    mean, std = fit_scaler([[0.0], [10.0]])  # mean 5, std 5
    assert normalize([[value]], mean, std)[0, 0] == pytest.approx(expected)


def test_constant_column_does_not_divide_by_zero():
    X = np.array([[7.0], [7.0], [7.0]])
    mean, std = fit_scaler(X)
    assert np.all(np.isfinite(normalize(X, mean, std)))


def test_empty_data_raises_error():
    with pytest.raises(ValueError):
        fit_scaler(np.empty((0, 4)))
