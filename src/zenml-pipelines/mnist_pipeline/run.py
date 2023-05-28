import click
from pipelines.mnist_pipeline import mnist_pipeline


@click.command()
@click.option("--epochs", default=5, help="Number of epochs for training")
@click.option("--lr", default=0.001, help="Learning rate for training")
def main(epochs: int, lr: float, stop_tensorboard: bool):
    # Run the pipeline
    mnist_pipeline(epochs=epochs, lr=lr)


if __name__ == "__main__":
    main()
