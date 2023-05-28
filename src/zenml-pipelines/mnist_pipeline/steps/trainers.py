import os

import numpy as np
import tensorflow as tf

from zenml import step
from zenml.steps import StepContext


@step(enable_cache=True)
def trainer(
    X_train: np.ndarray,
    y_train: np.ndarray,
    context: StepContext,
    epochs: int = 5,
    lr: float = 0.001,
) -> tf.keras.Model:
    """Train a neural net from scratch to recognize MNIST digits return our
    model or the learner."""
    model = tf.keras.Sequential(
        [
            tf.keras.layers.Flatten(input_shape=(28, 28)),
            tf.keras.layers.Dense(10, activation="relu"),
            tf.keras.layers.Dense(10),
        ]
    )

    log_dir = os.path.join(context.get_output_artifact_uri(), "logs")
    tensorboard_callback = tf.keras.callbacks.TensorBoard(
        log_dir=log_dir, histogram_freq=1
    )

    model.compile(
        optimizer=tf.keras.optimizers.Adam(lr),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=["accuracy"],
    )

    model.fit(
        X_train,
        y_train,
        epochs=epochs,
        callbacks=[tensorboard_callback],
    )

    return model
