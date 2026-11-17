# Lab 1: Git, CI/CD and Docker

## Deliverables

## Q1. Why forbid direct pushes to main?

main is the branch we deploy, so it must always work. With a Pull Request, a teammate reviews the change and the CI checks it before the merge. Nobody can break main by mistake, and the history shows who changed what and why.

## Q2. What is the difference between an image and a container?

An image is a read-only template built from the Dockerfile, made of layers. A container is a running instance of an image, with its own process and a writable layer on top. One image can start many containers.

## Q3. Image size compared with a non-slim base image

| Image | Base image | Disk usage | Content size |
|---|---|---|---|
| myapp:full | eclipse-temurin:21-jdk (Ubuntu) | 762 MB | 243 MB |
| myapp:0.1 (our Dockerfile) | eclipse-temurin:21-jdk-alpine | 591 MB | 202 MB |
| myapp:jre | eclipse-temurin:21-jre-alpine | 324 MB | 92.3 MB |

Disk usage is the uncompressed size on disk, content size is the compressed size (about what is pulled from a registry). The full and jre images were built only to compare sizes, without the non-root user.

Alpine instead of Ubuntu saves about 170 MB. Using a JRE instead of a JDK saves even more, about 270 MB, because the JDK ships the compiler and dev tools we don't need to run a jar. A smaller image is faster to pull in the pipeline and contains fewer packages that could have vulnerabilities.


