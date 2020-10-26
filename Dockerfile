# This Dockerfile defines the developer's environment for running all the tests.
FROM debian:sid-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    python-pip \
    python3 && \
    pip install pre-commit && \
    mkdir /pre-commit && \
    cd /pre-commit && \
    git init . && \
    pre-commit install

WORKDIR /pre-commit

CMD ["pre-commit", "run", "--all-files"]
