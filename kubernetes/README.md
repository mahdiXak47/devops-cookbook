### get-access.sh (TempAccess helper for Kubernetes namespaces)

A tiny helper that switches the current `kubectl` namespace using `kubens`, generates a short‑lived TempAccess YAML for that namespace, and applies it with `kubectl`.

#### Prerequisites
- `kubectl` configured for the target cluster.
- `kubens` (from `kubectx`) available in `PATH`.
- The `TempAccess` CRD (`security.hamravesh.com/v1alpha1`) installed on the cluster.
- macOS or Linux shell with `bash`.

#### Usage
You can run the script directly or via an alias named `knn` (the script prints `Usage: knn <namespace>`).

```bash
# Direct execution
./kubernetes/get-access.sh <namespace>

# Optional: install an alias named 'knn'
alias knn="$PWD/kubernetes/get-access.sh"
knn <namespace>
```

Example:
```bash
./kubernetes/get-access.sh staging-app
```

#### What the script does
1. Validates one argument `<namespace>` is provided.
2. Runs `kubens <namespace>` and verifies success by checking the final line equals:  
   `Active namespace is "<namespace>".`
3. Ensures directory: `$HOME/hamravesh/access-yamls/kubernetes-namespace-access`.
4. Writes `${NAMESPACE}-pod-access.yaml` with:
   - apiVersion: `security.hamravesh.com/v1alpha1`
   - kind: `TempAccess`
   - metadata.name: `debug-the-issue-in-namespace-<namespace>`
   - spec.username: `hamravesh:mahdixak04akbari`
   - spec.ttl: `2h`
   - spec.rules: full access to the specified namespace.
5. Applies the YAML with `kubectl apply -f ...`.

#### Expected output (abridged)
```text
>>> Running: kubens <namespace>
Active namespace is "<namespace>".
>>> Ensuring directory exists: $HOME/hamravesh/access-yamls/kubernetes-namespace-access
>>> Creating YAML: $HOME/hamravesh/access-yamls/kubernetes-namespace-access/<namespace>-pod-access.yaml
>>> Applying the YAML
<kubectl apply output...>
```

#### Troubleshooting
- Error: `'kubens <namespace>' failed` — Ensure `kubens` is installed and the namespace exists.
- Error: `Unexpected last line` — Your `kubens` version/output format may differ; update `kubens` or adjust the script check.
- `kubectl apply` fails with unknown resource — The `TempAccess` CRD is not installed on the cluster.
- YAML path issues — Verify you have write permissions to `$HOME/hamravesh/access-yamls/kubernetes-namespace-access`.

#### Notes
- The script writes YAML files under `$HOME/hamravesh/access-yamls/kubernetes-namespace-access`.
- The access TTL is set to `2h` by default; change inside the script if needed.


