import numpy as np

from zenml import step
from zenml.steps import Output


@step
def normalizer(
    X_train: np.ndarray, X_test: np.ndarray
) -> Output(X_train_normed=np.ndarray, X_test_normed=np.ndarray):
    """Normalize digits dataset with mean and standard deviation."""
    X_train_normed = (X_train - np.mean(X_train)) / np.std(X_train)
    X_test_normed = (X_test - np.mean(X_test)) / np.std(X_test)
    return X_train_normed, X_test_normed
