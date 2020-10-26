# This Dockerfile defines the developer's environment for running all the tests.
FROM python:3.6-slim-buster

RUN curl -L "$(curl -s https://api.github.com/repos/tfsec/tfsec/releases/latest | grep -o -E "https://.+?tfsec-linux-amd64")" > tfsec \
    && \
    chmod +x tfsec \
    && \
    sudo mv tfsec /usr/local/bin/

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
    sudo mv tflint /usr/local/bin/ \
    && \
    echo "Newest release: $(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")"

# FIXME https://github.com/tfsec/tfsec/releases/download/v0.34.0/tfsec-linux-amd64
# https://github.com/terraform-docs/terraform-docs/releases/download/v0.10.1/terraform-docs-v0.10.1-linux-amd64
# https://github.com/terraform-linters/tflint/releases/download/v0.20.3/tflint_linux_amd64.zip

RUN pip install pre-commit==2.7.1

CMD ["pre-commit", "run", "--all-files"]
