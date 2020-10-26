# This Dockerfile defines the developer's environment for running all the tests.
FROM python:3.6-slim-buster

RUN echo -e 'import sys, urllib.request\nurllib.request.urlretrieve(sys.argv[1], "this")' > curl.py

RUN python curl.py https://github.com/tfsec/tfsec/releases/download/v0.34.0/tfsec-linux-amd64 \
    && \
    chmod +x this \
    && \
    sudo mv this /usr/local/bin/tfsec \
    && \
    true
# FIXME echo "Newest release: $(wget -qO - https://api.github.com/repos/tfsec/tfsec/releases/latest | grep -o -E "https://.+?tfsec-linux-amd64")"

RUN python curl.py https://github.com/terraform-docs/terraform-docs/releases/download/v0.10.1/terraform-docs-v0.10.1-linux-amd64 \
    && \
    chmod +x this \
    && \
    sudo mv this /usr/local/bin/terraform-docs \
    && \
    true
# FIXME echo "Newest release: $(wget -qO - https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E "https://.+?-linux-amd64")"

RUN python curl.py https://github.com/terraform-linters/tflint/releases/download/v0.20.3/tflint_linux_amd64.zip \
    mv this tflint.zip \
    && \
    unzip tflint.zip \
    && \
    rm tflint.zip \
    && \
    sudo mv tflint /usr/local/bin/ \
    && \
    true
# FIXME echo "Newest release: $(wget -qO - https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")"

RUN pip install pre-commit==2.7.1

CMD ["pre-commit", "run", "--all-files"]
