#!/usr/bin/env bash
set -euo pipefail

# Run the ZAP Automation Framework plan inside the ZAP docker image.
#
# Usage:
#   ./scripts/run_zap_automation_docker.sh --ClientID someval --ApiKey secret
#
# Environment variables:
#   ClientID and ApiKey may also be set in the environment instead of passing
#   as arguments.

# 
LOCAL_API_FILE="api.yaml"
LOCAL_PLAN_FILE="automation.yaml"

# TODO: 2025-11-11 pin ZAP because of changes in newer versions

IMAGE="zaproxy/zap-stable:20251021"
PLAN_PATH="/zap/wrk/$LOCAL_PLAN_FILE"
API_PATH="/zap/wrk/api.iat.yaml"
ZAP_TARGET="https://mydomain.com"
ClientID="${ClientID:-}"
ApiKey="${ApiKey:-}"

show_help() {
  cat <<EOF
Usage: $0 [--ClientID VAL] [--ApiKey VAL] [--image IMAGE]

Runs the ZAP Automation Framework plan (automation/plan_full_scan.yaml)
inside the ZAP Docker image. The current working directory is mounted into
the container at /zap/wrk so generated reports will be available locally.

  Examples:
  ClientID=someval ApiKey=secret $0
  $0 --ClientID someval --ApiKey secret

Options:
  --ClientID VAL   ClientID header value (can also be set via ClientID env)
  --ApiKey VAL   ApiKey header value (can also be set via ApiKey env)
  --image IMAGE    Override the ZAP docker image (default: $IMAGE)
  -h, --help       Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ClientID)
      ClientID="$2"; shift 2;;
    --ApiKey)
      ApiKey="$2"; shift 2;;
    --image)
      IMAGE="$2"; shift 2;;
    -h|--help)
      show_help; exit 0;;
    *)
      echo "Unknown arg: $1" >&2; show_help; exit 2;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found in PATH. Install Docker Desktop or ensure docker CLI is available." >&2
  exit 3
fi

if [ -z "$ClientID" ] || [ -z "$ApiKey" ]; then
  echo "Warning: ClientID or ApiKey not provided. The plan will run but headers may be empty." >&2
  echo "Set ClientID and ApiKey via env or --ClientID/--ApiKey flags to inject headers." >&2
fi

if [ ! -f "$LOCAL_API_FILE" ]; then
  echo "Api file $LOCAL_API_FILE not found in $(pwd)" >&2
  exit 4
fi

if [ ! -f "$LOCAL_PLAN_FILE" ]; then
  echo "Plan file $LOCAL_PLAN_FILE not found in $(pwd)" >&2
  exit 4
fi

echo "Running ZAP automation plan with image: $IMAGE"
echo "ClientID=${ClientID:+***set***}" "ApiKey=${ApiKey:+***set***}"

# create directory to output test reports to
mkdir zap-report-html

# Start ZAP in daemon (headless) mode and autorun the plan. The daemon mode
# prevents ZAP from attempting to start the GUI in headless environments.
docker run --rm -v "$(pwd)":/zap/wrk \
  -e OPENAPI_FILE="$API_PATH" -e ClientID="$ClientID" -e ApiKey="$ApiKey" -e ZAP_TARGET="$ZAP_TARGET" -e ZAP_WORK_DIR="/zap/wrk" \
  "$IMAGE" \
  zap.sh -cmd -config api.disablekey=true -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true \
    -autorun "$PLAN_PATH"

echo "Finished. If the plan produced reports they will be in: $(pwd)/report.html and $(pwd)/alerts.json (or check /zap/wrk)."
