#!/usr/bin/env bash

# devbox (Nix) が GNU coreutils 等のビルド依存ツールを PATH の先頭付近に
# 追加するため、macOS のシステムコマンド (ls, grep, sed 等) が上書きされる。
# この問題は devbox の既知の課題: https://github.com/jetify-com/devbox/issues/1509
#
# 対処: stdenv 由来のパスを PATH 末尾に移動し、macOS のコマンドを優先させる。
# devbox が明示的にインストールしたパッケージ (.devbox/nix/profile/default/bin)
# やビルドツールチェイン (clang 等) はそのまま維持する。

_devbox_fix_path() {
  local new_path=""
  local nix_stdenv_paths=""
  local IFS=':'

  for p in $PATH; do
    case "$p" in
      /nix/store/*-coreutils-*/bin|\
      /nix/store/*-gnugrep-*/bin|\
      /nix/store/*-gnused-*/bin|\
      /nix/store/*-gawk-*/bin|\
      /nix/store/*-findutils-*/bin|\
      /nix/store/*-diffutils-*/bin|\
      /nix/store/*-gnutar-*/bin|\
      /nix/store/*-gzip-*/bin|\
      /nix/store/*-bzip2-*/bin|\
      /nix/store/*-gnumake-*/bin|\
      /nix/store/*-patch-[0-9]*/bin|\
      /nix/store/*-xz-*/bin|\
      /nix/store/*-file-[0-9]*/bin|\
      /nix/store/*-bash-*/bin)
        nix_stdenv_paths="${nix_stdenv_paths:+$nix_stdenv_paths:}$p"
        ;;
      *)
        new_path="${new_path:+$new_path:}$p"
        ;;
    esac
  done

  # stdenv のパスを末尾に追加（ビルド時のフォールバックとして残す）
  export PATH="${new_path}${nix_stdenv_paths:+:$nix_stdenv_paths}"
}

_devbox_fix_path
unset -f _devbox_fix_path
