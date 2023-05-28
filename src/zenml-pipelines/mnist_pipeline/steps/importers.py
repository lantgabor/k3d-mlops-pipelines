import numpy as np
import tensorflow as tf

from zenml import step
from zenml.steps import Output


@step
def importer() -> (
    Output(
        X_train=np.ndarray,
        X_test=np.ndarray,
        y_train=np.ndarray,
        y_test=np.ndarray,
    )
):
    """Download the MNIST data store it as an artifact."""
    (X_train, y_train), (
        X_test,
        y_test,
    ) = tf.keras.datasets.mnist.load_data()
    return X_train, X_test, y_train, y_test
