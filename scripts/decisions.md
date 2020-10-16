# Architecture Decision Record (ADR) For Tests and CI/CD

## macOS and Linux

- Decision: Tests compatible with macOS and Linux, including WSL1 and WSL2.
- Reason: Those are the main systems of our users and our developers.

## Microsoft Windows (non-WSL)

- Decision: Maintain open road for test compatibility with Microsoft Windows (non-WSL).
- Reason: predictable customer requirements.

## GitHub Actions for CI/CD

- Decision: Use GitHub Actions for CI/CD.
- Reason: The code was placed on GitHub. Therefore it's just the easiest CI/CD runner to implement.

## CLI Commands

- Decision: Have a command that is runnable from a laptop that runs all the tests. Run exactly the same command in CI/CD.
- Reason: Short feedback loop when developing. It takes less time to run locally the same actions that CI/CD normally does. Time is saved on git-committing, git-pushing, preparing the fresh runner containers.
- Reason: Less vendor lock-in with GitHub Actions (or any other CI/CD runner).

## Python

- Decision: Use Python 3.6 script as the command for the main test.
- Alternative was: Use bash script as the command for the main test.
- Reason: Less pitfalls, cleaner syntax.
- Reason: Predicted MS Windows compatibility.
- Cost: Need to install Python and set it up.

## Test the examples

- Decision: Test the examples to the maximum extent possible, including `terraform apply` on a real cloud.
- Reason: Examples are by far the main contact point of any developer
who starts work on the modules. Typically a developer tries to copy
a relevant  example, do minimal customizations and it would be best if they could simply succeed. A successful first run enables to enter a feedback loop and become productive on the main project.
