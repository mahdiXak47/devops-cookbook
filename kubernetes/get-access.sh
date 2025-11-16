#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: knn <namespace>" >&2
  exit 1
fi

NAMESPACE="$1"

echo ">>> Running: kubens $NAMESPACE"
OUTPUT="$(kubens "$NAMESPACE" 2>&1 || true)"
STATUS=$?

printf "%s\n" "$OUTPUT"

if [ "$STATUS" -ne 0 ]; then
  echo "Error: 'kubens $NAMESPACE' failed (exit $STATUS)" >&2
  exit "$STATUS"
fi

LAST_LINE="$(printf "%s\n" "$OUTPUT" | tail -n 1 | tr -d '\r')"
EXPECTED="Active namespace is \"$NAMESPACE\"."

if [ "$LAST_LINE" != "$EXPECTED" ]; then
  echo "Error: Unexpected last line: $LAST_LINE" >&2
  exit 1
fi

TARGET_DIR="$HOME/hamravesh/access-yamls/kubernetes-namespace-access"
echo ">>> Ensuring directory exists: $TARGET_DIR"
mkdir -p "$TARGET_DIR"

YAML_FILE="${NAMESPACE}-pod-access.yaml"
YAML_PATH="${TARGET_DIR}/${YAML_FILE}"

echo ">>> Creating YAML: $YAML_PATH"

cat > "$YAML_PATH" <<EOF
apiVersion: security.hamravesh.com/v1alpha1
kind: TempAccess
metadata:
  name: debug-the-issue-in-namespace-${NAMESPACE}
spec:
  username: hamravesh:mahdixak04akbari
  ttl: 2h
  rules:
    - namespace: ${NAMESPACE}
      apiGroups: ["*"]
      resources: ["*"]
      verbs: ["*"]
EOF

echo ">>> Applying the YAML"
kubectl apply -f "$YAML_PATH"
