# Solution – Scenario 06: Create Canary Deployment with Manual Traffic Split

## Step 1 – Scale the existing Deployment to 8 replicas

```bash
kubectl scale deploy web-app --replicas=8
```

Verify:

```bash
kubectl get deploy web-app
```

## Step 2 – Create the canary Deployment

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-canary
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
      version: v2
  template:
    metadata:
      labels:
        app: webapp
        version: v2
    spec:
      containers:
        - name: nginx
          image: nginx:1.24
          ports:
            - containerPort: 80
EOF
```

## Step 3 – Verify traffic split

Check both deployments are running:

```bash
kubectl get deploy web-app web-app-canary
```

Check that the Service endpoints include pods from both:

```bash
kubectl get endpoints web-service
kubectl get pods -l app=webapp --show-labels
```

You should see 10 total pods (8 with version=v1, 2 with version=v2), and all 10 IPs should appear in the Service endpoints.

## Key Concepts

- The Service selector `app=webapp` matches both deployments since both have that label
- Traffic is distributed proportionally by replica count (80/20 split)
- The `selector.matchLabels` in each Deployment must be unique to avoid ownership conflicts
