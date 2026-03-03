#!/usr/bin/env bash
set -euo pipefail

WEB_PORT="${WEB_PORT:-8082}"
API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:8000}"
WATCH_PATHS=(lib web pubspec.yaml pubspec.lock)

compute_fingerprint() {
  # Watch only source/config files to avoid infinite reload loops.
  find "${WATCH_PATHS[@]}" -type f 2>/dev/null \
    | sort \
    | xargs -r stat -c '%n:%Y' \
    | sha1sum \
    | awk '{print $1}'
}

flutter config --enable-web >/dev/null
flutter pub get >/dev/null

echo "[flutter-dev] Starting web server on port ${WEB_PORT}..."

coproc FLUTTER_RUN {
  flutter run \
    -d web-server \
    --web-hostname=0.0.0.0 \
    --web-port="${WEB_PORT}" \
    --dart-define="API_BASE_URL=${API_BASE_URL}"
}

sleep 3
last_fingerprint="$(compute_fingerprint || true)"

while kill -0 "${FLUTTER_RUN_PID}" 2>/dev/null; do
  current_fingerprint="$(compute_fingerprint || true)"
  if [[ -n "${last_fingerprint}" && "${current_fingerprint}" != "${last_fingerprint}" ]]; then
    echo "[flutter-dev] Change detected, triggering hot reload..."
    printf 'r\n' >&"${FLUTTER_RUN[1]}" || true
    sleep 1
  fi
  last_fingerprint="${current_fingerprint}"
  sleep 1
done

wait "${FLUTTER_RUN_PID}"
