# k9s

[k9s](https://k9scli.io/) is a terminal-based Kubernetes cluster manager that provides a rich UI for interacting with clusters.

## Tracked Files

| File | Purpose |
|------|---------|
| `config.yaml` | Global k9s settings: UI preferences, refresh rate, logger config, resource thresholds, shell pod image |
| `aliases.yaml` | Short aliases for navigating to resource views (e.g., type `dp` to jump to Deployments) |
| `views.yaml` | Custom column layouts for resource views (pods show image version, app/component labels, resource usage) |

## Aliases Defined

| Alias | Resource |
|-------|----------|
| `dp` | Deployments |
| `sec` | Secrets |
| `jo` | Jobs |
| `cr` | ClusterRoles |
| `crb` | ClusterRoleBindings |
| `ro` | Roles |
| `rb` | RoleBindings |
| `np` | NetworkPolicies |

## Clusters Directory

The `clusters/` directory is not tracked because it contains machine-specific cluster configurations.

k9s auto-generates cluster configs when you connect to a cluster. The structure is:

```
clusters/
  <cluster-arn-or-name>/
    <context-name>/
      config.yaml       # Cluster-specific namespace, view, feature settings
      benchmarks.yaml   # Performance benchmarks
```

An `example-cluster.yaml` template is included showing the expected structure.

## Setup on a New Machine

1. Run `install.sh` to symlink the tracked config files to `~/.config/k9s/`.
2. Connect to your Kubernetes clusters (`kubectl config use-context ...`).
3. Launch `k9s` -- it will auto-generate cluster-specific configs in `~/.config/k9s/clusters/`.
4. Customize namespace favorites per cluster as needed.
