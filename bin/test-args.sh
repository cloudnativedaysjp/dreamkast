#!/usr/bin/env bash
echo "Arguments received:"
echo "Count: $#"
echo "All args: $*"
for i in "$@"; do
  echo "  - $i"
done
