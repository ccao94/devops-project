# Lab 1: Git, CI/CD and Docker

## Deliverables

## Q1. Why forbid direct pushes to main?

main is the branch we deploy, so it must always work. With a Pull Request, a teammate reviews the change and the CI checks it before the merge. Nobody can break main by mistake, and the history shows who changed what and why.