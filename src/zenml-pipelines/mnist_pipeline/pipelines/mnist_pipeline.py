from steps.evaluators import evaluator
from steps.importers import importer
from steps.normalizers import normalizer
from steps.trainers import trainer

from zenml import pipeline
from zenml.config import DockerSettings
from zenml.integrations.constants import TENSORFLOW

docker_settings = DockerSettings(required_integrations=[TENSORFLOW])


@pipeline(enable_cache=True, settings={"docker": docker_settings})
def mnist_pipeline(epochs: int = 10, lr: float = 0.001):
    X_train, X_test, y_train, y_test = importer()
    X_trained_normed, X_test_normed = normalizer(X_train=X_train, X_test=X_test)
    model = trainer(X_train=X_trained_normed, y_train=y_train, epochs=epochs, lr=lr)
    evaluator(X_test=X_test_normed, y_test=y_test, model=model)
