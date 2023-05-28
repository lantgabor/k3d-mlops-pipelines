import logging

import numpy as np
import tensorflow as tf

from zenml import step


@step
def evaluator(
    X_test: np.ndarray,
    y_test: np.ndarray,
    model: tf.keras.Model,
) -> float:
    """Calculate the accuracy on the test set."""
    _, test_acc = model.evaluate(X_test, y_test, verbose=2)
    logging.info(f"Test accuracy: {test_acc}")
    return test_acc
