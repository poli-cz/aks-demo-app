# Helm Guide — AKS Demo App

This guide explains how **Helm** is used in this repository and demonstrates the full lifecycle of a Helm-managed deployment.

It is designed to clearly show:

- How templates work (**templates → rendered YAML**)
- How `values.yaml` controls behavior (**configuration as data**)
- How **install / upgrade / rollback** work (release lifecycle)
- How Helm differs from **raw Kubernetes manifests**

---

## Prerequisites

- You have this repository cloned locally.
- You have a Kubernetes cluster context configured (AKS or any Kubernetes cluster):
  - `kubectl cluster-info` works
- Helm v3 is installed:
  - `helm version` works

Optional but helpful:
- `kubectl` (of course)
- `diff` (or `git diff`)
- `yq` (for YAML inspection)

---

## Helm Mental Model

Helm operates in three stages:

```
Chart (templates + values)
        ↓
Rendered Kubernetes YAML
        ↓
Kubernetes API
```

Helm does **not** replace Kubernetes.
It **generates Kubernetes manifests**, applies them to the cluster, and stores **release metadata** (including revision history).

---

## Chart Location & Structure

The Helm chart lives in:

```
helm/aks-demo-app/
```

Typical structure:

```
helm/aks-demo-app/
  Chart.yaml
  values.yaml
  values-dev.yaml
  values-prod.yaml
  templates/
    deployment.yaml
    service.yaml
    configmap.yaml
    secret.yaml
    hpa.yaml
    _helpers.tpl
```

### What each file is for

- `Chart.yaml` — chart metadata (name, version, description)
- `values.yaml` — default values (base configuration)
- `values-*.yaml` — environment overrides (dev/prod differences)
- `templates/*.yaml` — Kubernetes templates with `{{ ... }}` Helm logic
- `_helpers.tpl` — reusable template functions (naming, labels, etc.)

---

## Inspecting the Chart

### View chart metadata

```bash
cat helm/aks-demo-app/Chart.yaml
```

### Validate chart structure

```bash
helm lint helm/aks-demo-app
```

---

## Render Templates (No Deployment)

One of the most important Helm commands is:

```bash
helm template demo helm/aks-demo-app -n demo
```

This renders templates into plain Kubernetes YAML **without** applying anything to the cluster.
It shows the **exact YAML** Helm would send to Kubernetes.

### Render for a specific environment

**Dev**:

```bash
helm template demo helm/aks-demo-app \
  -n demo \
  -f helm/aks-demo-app/values-dev.yaml
```

**Prod**:

```bash
helm template demo helm/aks-demo-app \
  -n demo \
  -f helm/aks-demo-app/values-prod.yaml
```

### Compare environments

```bash
helm template demo helm/aks-demo-app -n demo -f helm/aks-demo-app/values-dev.yaml  > /tmp/dev.yaml
helm template demo helm/aks-demo-app -n demo -f helm/aks-demo-app/values-prod.yaml > /tmp/prod.yaml
diff -u /tmp/dev.yaml /tmp/prod.yaml
```

This typically demonstrates differences such as:

- Replica count differences
- Service type differences (e.g., `ClusterIP` vs `LoadBalancer`)
- HPA enabled/disabled
- Resource requests/limits differences

---

## Quick Variables (Optional)

To reduce typing, you can use:

```bash
export NS=demo
export RELEASE=demo
export CHART=helm/aks-demo-app
```

Then use `$NS`, `$RELEASE`, `$CHART` in commands.

---

## Install a Release

Install using the **dev** configuration:

```bash
helm install demo helm/aks-demo-app \
  -n demo \
  --create-namespace \
  -f helm/aks-demo-app/values-dev.yaml
```

### Verify install

```bash
helm -n demo list
helm -n demo status demo
kubectl -n demo get pods,svc
```

Tip: if you want to see **everything** created:

```bash
kubectl -n demo get all
```

---

## Upgrade a Release

Upgrades re-render templates with new values and apply the resulting changes.

### Example: change replica count dynamically

```bash
helm upgrade demo helm/aks-demo-app \
  -n demo \
  -f helm/aks-demo-app/values-dev.yaml \
  --set replicaCount=3
```

### Watch the rollout

```bash
kubectl -n demo rollout status deployment/demo
kubectl -n demo get pods
```

---

## Release History

Helm stores every revision of the release.

```bash
helm history demo -n demo
```

This shows all revisions, timestamps, and statuses.

---

## Rollback

Rollback restores the **exact stored manifest** of a previous revision.

Rollback to revision `1`:

```bash
helm rollback demo 1 -n demo
```

Observe the pod replacement and rollout:

```bash
kubectl -n demo get pods -w
```

---

## Inspect a Release

### Show applied values

```bash
helm get values demo -n demo
```

Add `--all` to include defaults too:

```bash
helm get values demo -n demo --all
```

### Show the rendered manifest stored by Helm

```bash
helm get manifest demo -n demo
```

This is extremely useful for auditing: _“What is actually deployed?”_

---

## Uninstall (Delete the Release)

Remove everything Helm created for that release:

```bash
helm uninstall demo -n demo
```

Verify:

```bash
kubectl -n demo get all
```

---

## Dry-Run Mode

Preview an install or upgrade **without applying** changes:

```bash
helm upgrade demo helm/aks-demo-app \
  -n demo \
  -f helm/aks-demo-app/values-dev.yaml \
  --dry-run
```

If you also want to see the rendered YAML output:

```bash
helm upgrade demo helm/aks-demo-app \
  -n demo \
  -f helm/aks-demo-app/values-dev.yaml \
  --dry-run \
  --debug
```

---

## Debug Mode

If templates fail or you need more context:

```bash
helm template demo helm/aks-demo-app --debug
```

Or during installation:

```bash
helm install demo helm/aks-demo-app \
  -n demo \
  -f helm/aks-demo-app/values-dev.yaml \
  --debug
```

---

## Key Helm Commands Summary

| Command | Purpose |
|---|---|
| `helm lint` | Validate chart structure |
| `helm template` | Render without deploy |
| `helm install` | First deployment |
| `helm upgrade` | Modify existing release |
| `helm upgrade --install` | Idempotent deployment |
| `helm history` | View revision history |
| `helm rollback` | Restore old release version |
| `helm get values` | Inspect active values |
| `helm get manifest` | View stored manifest |
| `helm uninstall` | Delete release |
| `helm list` | Show releases in namespace |

---

## Helm vs Raw YAML

### Raw YAML advantages

- Simple and explicit
- Transparent
- Easy to debug initially

### Helm advantages

- Reusability (parameterized templates)
- Configuration via `values.yaml`
- Environment separation (dev/prod)
- Versioned release history
- Built-in rollback
- GitOps-ready patterns

---

## Common Troubleshooting

### “cannot re-use a name that is still in use”

You tried to install a release name that already exists in the namespace.

Fix:

```bash
helm -n demo list
helm uninstall demo -n demo
```

Or upgrade instead of install:

```bash
helm upgrade --install demo helm/aks-demo-app -n demo -f helm/aks-demo-app/values-dev.yaml
```

### Pods stuck in `ImagePullBackOff`

Usually means the image reference is wrong or registry auth is missing.

Check:

```bash
kubectl -n demo describe pod <pod-name>
kubectl -n demo get events --sort-by=.lastTimestamp
```

### Template errors (YAML parse / missing values)

Render locally and inspect:

```bash
helm template demo helm/aks-demo-app -n demo -f helm/aks-demo-app/values-dev.yaml --debug > /tmp/rendered.yaml
```

Then open `/tmp/rendered.yaml` and locate the invalid section.

---

## Best Practices (Workshop-Friendly)

- Prefer `helm upgrade --install` for repeatable workflows.
- Use `--wait` to wait for resources to become ready:
  ```bash
  helm upgrade --install demo helm/aks-demo-app -n demo -f helm/aks-demo-app/values-dev.yaml --wait
  ```
- Use `--atomic` to auto-rollback if upgrade fails:
  ```bash
  helm upgrade --install demo helm/aks-demo-app -n demo -f helm/aks-demo-app/values-dev.yaml --atomic --wait
  ```
- Keep environment overrides small (`values-dev.yaml`, `values-prod.yaml` only override what differs).
- Avoid storing secrets in plain text; prefer external secret solutions for real projects.

---

## Next Evolution

This chart can evolve to include:

- Ingress support (with TLS)
- Externalize secrets via Azure Key Vault + External Secrets Operator
- Package and version the chart (`helm package`)
- Publish to a Helm registry
- Integrate with Flux for GitOps deployments

---

## Appendix: Minimal End-to-End Demo

```bash
# Render
helm template demo helm/aks-demo-app -n demo -f helm/aks-demo-app/values-dev.yaml

# Install
helm install demo helm/aks-demo-app -n demo --create-namespace -f helm/aks-demo-app/values-dev.yaml

# Upgrade (change replicas)
helm upgrade demo helm/aks-demo-app -n demo -f helm/aks-demo-app/values-dev.yaml --set replicaCount=3

# History
helm history demo -n demo

# Rollback
helm rollback demo 1 -n demo

# Inspect
helm get values demo -n demo
helm get manifest demo -n demo

# Uninstall
helm uninstall demo -n demo
```
