# Solution – Scenario 05: Build Container Image with Podman

## Step 1 – Build the image

```bash
cd /root/app-source
podman build -t my-app:1.0 .
```

Verify the image was created:

```bash
podman images | grep my-app
```

## Step 2 – Save the image as a tarball

```bash
podman save -o /root/my-app.tar my-app:1.0
```

Verify the tarball exists:

```bash
ls -lh /root/my-app.tar
```

## Alternative (using Docker)

If Podman is not available:

```bash
cd /root/app-source
docker build -t my-app:1.0 .
docker save -o /root/my-app.tar my-app:1.0
```

## Verification

```bash
# Image exists
podman images my-app:1.0

# Tarball exists and is non-empty
test -s /root/my-app.tar && echo "PASS" || echo "FAIL"
```
