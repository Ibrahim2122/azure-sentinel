#!/usr/bin/env zsh
# Simulate SSH brute force using sshpass (lab/demo only)
# Usage: ./simulate_ssh_bruteforce.sh <user> <host> <port:optional> <attempts:optional>
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <user> <host> [port=22] [attempts=30]"
  exit 1
fi

USER="$1"
HOST="$2"
PORT="${3:-22}"
ATTEMPTS="${4:-30}"

for i in $(seq 1 $ATTEMPTS); do
  # wrong password on purpose
  sshpass -p "NotTheRightPassword$i" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p "$PORT" "$USER@$HOST" "exit" || true
  sleep 0.5
done

echo "Done. Generated ~$ATTEMPTS failed SSH attempts against $HOST."