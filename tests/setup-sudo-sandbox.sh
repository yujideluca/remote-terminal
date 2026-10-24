#!/usr/bin/env bash
# Runs setup-sudo.sh in a throwaway root (bubblewrap) with stubbed apt-get, curl, systemctl, sshd and tailscale.
# Nothing on the real system changes. Not covered: real package installs and a real sshd (the stubs only record calls).
set -euo pipefail
cd "$(dirname "$0")/.."
command -v bwrap >/dev/null || { echo "bwrap not installed (skipped)"; exit 0; }
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
mkdir -p "$work/stubs" "$work/log"
for c in apt-get systemctl tailscale tailscaled sshd; do
  printf '#!/bin/bash\necho "%s $*" >> /log/calls.txt\n' "$c" > "$work/stubs/$c"
done
# sshd -t must fail when the config file was not written; tailscale ip prints an address
printf '[ -f /etc/ssh/sshd_config.d/10-phone.conf ] || exit 1\n' >> "$work/stubs/sshd"
printf '[ "$1" = ip ] && echo 100.64.0.1\nexit 0\n' >> "$work/stubs/tailscale"
printf '#!/bin/bash\necho "curl $*" >> /log/calls.txt\nwhile [ $# -gt 0 ]; do [ "$1" = -o ] && echo stub > "$2"; shift; done\n' > "$work/stubs/curl"
chmod +x "$work"/stubs/*
# user yuji maps to root inside the sandbox, so chown works without real privileges
printf 'root:x:0:0:r:/root:/bin/bash\nyuji:x:0:0:y:/home/yuji:/bin/bash\n' > "$work/passwd"
printf 'root:x:0:\nyuji:x:0:\n' > "$work/group"

sandbox() { # sandbox 'shell command' args...
  bwrap --unshare-user --uid 0 --gid 0 --unshare-pid --unshare-net \
    --ro-bind /usr /usr --symlink usr/bin /bin --symlink usr/lib /lib --symlink usr/lib64 /lib64 --symlink usr/sbin /sbin \
    --proc /proc --dev /dev --tmpfs /etc --tmpfs /home --tmpfs /tmp --tmpfs /var \
    --ro-bind "$work/passwd" /etc/passwd --ro-bind "$work/group" /etc/group \
    --bind "$work/log" /log --ro-bind "$work/stubs" /stubs --ro-bind setup-sudo.sh /setup-sudo.sh \
    --setenv PATH /stubs:/usr/bin:/usr/sbin --chdir / bash -c "$@"
}
fail() { echo "FAIL: $1"; exit 1; }
KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITESTKEYONLY phone"

[ "$(sandbox 'bash /setup-sudo.sh "not a key" >/dev/null 2>&1; echo $?; ls /home/yuji/.ssh 2>&1 | grep -c authorized_keys' _ | tr '\n' ' ')" = "1 0 " ] || fail "a bad key must stop the script and install nothing"
nonroot=$(bwrap --unshare-user --ro-bind /usr /usr --symlink usr/bin /bin --symlink usr/lib /lib --symlink usr/lib64 /lib64 --ro-bind setup-sudo.sh /s.sh bash /s.sh 2>&1 || true)
grep -qx "run with sudo" <<<"$nonroot" || fail "must refuse to run without root"

res=$(sandbox 'bash /setup-sudo.sh "$1" >/dev/null 2>&1; bash /setup-sudo.sh "$1" >/dev/null 2>&1; echo "$?"; grep -c . /home/yuji/.ssh/authorized_keys; stat -c %a /home/yuji/.ssh /home/yuji/.ssh/authorized_keys; cat /etc/ssh/sshd_config.d/10-phone.conf' _ "$KEY")
[ "$(sed -n 1p <<<"$res")" = 0 ] || fail "second run (idempotence) did not exit 0"
[ "$(sed -n 2p <<<"$res")" = 1 ] || fail "the phone key was added twice"
[ "$(sed -n 3,4p <<<"$res" | tr '\n' ' ')" = "700 600 " ] || fail "wrong permissions on .ssh"
grep -qx 'PasswordAuthentication no' <<<"$res" || fail "password login not disabled"
grep -qx 'AllowUsers yuji' <<<"$res" || fail "AllowUsers missing"
grep -q '^apt-get install -y openssh-server tailscale tmux' "$work/log/calls.txt" || fail "packages not installed"
echo "setup-sudo sandbox test ok"
