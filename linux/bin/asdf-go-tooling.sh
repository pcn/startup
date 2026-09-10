#!/usr/bin/env bash
# Install the standard Go tool set into every asdf-installed golang version.
#
# Why this exists: the asdf golang plugin sets GOPATH to
# $ASDF_INSTALL_PATH/packages, so `go install`ed tools land in a *per-version*
# tree and are exposed by per-version shims. A tool installed under golang
# 1.22.2 does not exist under 1.24.7. When a repo's .tool-versions pins a
# golang version that has no gopls, the shim exits 126 with "No version is set
# for command gopls" -- which eglot reports only as
# "[jsonrpc] Server exited with status 126 / Server died".
#
# So: after `asdf install golang <version>`, run this. It is idempotent.
#
#   ./asdf-go-tooling.sh              # every installed golang version
#   ./asdf-go-tooling.sh 1.24.7       # just these versions
#
# GOTOOLCHAIN=auto lets an older golang download the newer toolchain a modern
# tool requires to build; the resulting binary still lands in the older
# version's GOPATH/bin, which is what we want.

set -uo pipefail

TOOLS=(
  golang.org/x/tools/gopls@latest
  github.com/cweill/gotests/gotests@latest
  github.com/fatih/gomodifytags@latest
  github.com/josharian/impl@latest
  honnef.co/go/tools/cmd/staticcheck@latest
)

ASDF_GOLANG_DIR="${HOME}/.asdf/installs/golang"

if [[ ! -d "$ASDF_GOLANG_DIR" ]]; then
  echo "error: $ASDF_GOLANG_DIR does not exist; is the asdf golang plugin installed?" >&2
  exit 1
fi

if (($# > 0)); then
  versions=("$@")
else
  mapfile -t versions < <(ls -1 "$ASDF_GOLANG_DIR")
fi

if ((${#versions[@]} == 0)); then
  echo "error: no golang versions found under $ASDF_GOLANG_DIR" >&2
  exit 1
fi

failed=()

for version in "${versions[@]}"; do
  go_bin="${ASDF_GOLANG_DIR}/${version}/go/bin/go"
  gopath="${ASDF_GOLANG_DIR}/${version}/packages"

  if [[ ! -x "$go_bin" ]]; then
    echo "!! golang ${version}: no go binary at ${go_bin}, skipping" >&2
    failed+=("${version} (missing toolchain)")
    continue
  fi

  echo "== golang ${version} -> ${gopath}/bin"
  for tool in "${TOOLS[@]}"; do
    printf '   %-52s' "${tool}"
    if GOPATH="$gopath" GOBIN="${gopath}/bin" GOTOOLCHAIN=auto \
        "$go_bin" install "$tool" >/tmp/asdf-go-tooling.$$.log 2>&1; then
      echo "ok"
    else
      echo "FAILED"
      sed 's/^/      /' /tmp/asdf-go-tooling.$$.log >&2
      failed+=("${version}: ${tool}")
    fi
    rm -f /tmp/asdf-go-tooling.$$.log
  done
done

# Expose the newly installed binaries as asdf shims.
echo "== asdf reshim golang"
asdf reshim golang

if ((${#failed[@]} > 0)); then
  echo
  echo "!! ${#failed[@]} failure(s):" >&2
  printf '   %s\n' "${failed[@]}" >&2
  exit 1
fi

echo
echo "All tools installed for: ${versions[*]}"
