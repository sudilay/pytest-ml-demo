"""A tiny ML pipeline: load -> normalize -> train -> predict."""
import numpy as np
from sklearn.datasets import load_iris
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split


def load_data():
    """Return the Iris features X (150 x 4) and labels y."""
    return load_iris(return_X_y=True)


def fit_scaler(X):
    """Learn the mean and std of each column (from training data only)."""
    X = np.asarray(X, dtype=float)
    if X.size == 0:
        raise ValueError("Cannot fit a scaler on empty data")
    mean = X.mean(axis=0)
    std = X.std(axis=0)
    std[std == 0] = 1.0  # constant column: avoid division by zero
    return mean, std


def normalize(X, mean, std):
    """Z-score: every column gets mean 0 and std 1."""
    return (np.asarray(X, dtype=float) - mean) / std


def train(X, y, seed=42):
    return LogisticRegression(max_iter=200, random_state=seed).fit(X, y)


def predict(model, X):
    return model.predict(X)


def run_pipeline(seed=42):
    """Whole pipeline end to end. Returns (predictions, true labels)."""
    X, y = load_data()
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.3, stratify=y, random_state=seed
    )
    mean, std = fit_scaler(X_train)
    model = train(normalize(X_train, mean, std), y_train, seed)
    y_pred = predict(model, normalize(X_test, mean, std))
    return y_pred, y_test
