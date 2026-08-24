# Scenario 05 – Build Container Image with Podman and Save as Tarball

## Context

On the node, directory `/root/app-source` contains a valid `Dockerfile` and application files.

## Task

1. Build a container image using **Podman** with the tag `my-app:1.0` using `/root/app-source` as the build context
2. Save the built image as a tarball to `/root/my-app.tar`

## Requirements

- Image name and tag must be exactly `my-app:1.0`
- The tarball must be saved at `/root/my-app.tar`
- Use Podman commands (Docker commands are nearly identical if Podman is unavailable)

## Hints

- Use `podman build` to build images from a Dockerfile
- Use `podman save` to export an image as a tarball
- Verify with `podman images | grep my-app`

## Docs Reference

- https://kubernetes.io/docs/concepts/containers/images/
- https://docs.podman.io/
