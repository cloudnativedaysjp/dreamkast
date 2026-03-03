#!/usr/bin/env bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -d "$PROJECT_ROOT/node_modules" ] || \
   [ ! -d "$PROJECT_ROOT/vendor/bundle" ]; then
  echo "⚠️  初回セットアップが未完了です"
  echo "   devbox run setup を実行してください"
fi
