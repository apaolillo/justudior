# justudior

This repository holds the file to generate the Docker image (and run the
Docker container) containing the following tools:

- the R interpreter;
- Jupyter Notebook and associated tools (JupyterLabs, Voilà, etc.);
- the RStudio IDE (server version), running inside the container.

We also include the necessary packages and utilities to glue R and Jupyter
together.

Notice the name of the repo (and the tag of the Docker image) is `justudior`,
a contraction of "Jupyter", "Studio" and "R", recalling the tools contained in
the image.

## Prerequisites

The only prerequisites is to install Docker on a Linux machine.

One can use instructions provided on Docker website: https://docs.docker.com/engine/install/

## Building the image and running the container

Simply run the script located at the root of the repository:

```bash
./buildrun.sh
```

The image takes some time to build.

After the image is built, the script automatically runs the container that
starts `RStudio` and a `tmux` session with `Jupyter Notebook`, allowing you to
interact with a shell while Jupyter is running.

## Connecting to RStudio server

Once the container is started, `RStudio` starts listening on port 8787 (and the
port is exposed to the host).

On a browser on your host, you can connect to http://127.0.0.1:8787/ to access
the RStudio server.
Use the Linux user/password credentials pre-configured in the Dockerfile
(modify it according to your needs) to connect through the WebUI.

## Connecting to Jupyter Notebook

As the container starts, the tmux session loads Jupyter Notebook and provides
a URL with a token.
You can use the URL with the localhost IP address (127.0.0.1) to connect to
the WebUI of Jupyter Notebook, as the port 8888 is exposed to the host.
