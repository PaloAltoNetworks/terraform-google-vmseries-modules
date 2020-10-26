# This Dockerfile defines the developer's environment for running all the tests.
FROM debian:sid-slim

RUN go mod init dummy \
    # because cannot use path@version syntax in GOPATH mode
    && \
    export GO111MODULE=on \
    && \
    go get -u github.com/tfsec/tfsec/cmd/tfsec@v0.30.1 \
    && \
    sudo mv /home/runner/go/bin/tfsec /usr/local/bin/

RUN curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E "https://.+?-linux-amd64")" > terraform-docs \
    && \
    chmod +x terraform-docs \
    && \
    sudo mv terraform-docs /usr/local/bin/

RUN curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" > tflint.zip \
    && \
    unzip tflint.zip \
    && \
    rm tflint.zip \
    && \
    sudo mv tflint /usr/local/bin/

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    python3-pip \
    && \
    pip install pre-commit

CMD ["pre-commit", "run", "--all-files"]
