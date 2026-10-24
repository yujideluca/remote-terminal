#!/bin/bash
# Whole phone-terminal setup, safe to re-run: OpenSSH server (key-only) + Tailscale + phone key.
# Run in a normal terminal (no leading "!"):
#   sudo bash ~/dev/remote-terminal/setup-sudo.sh ["ssh-ed25519 AAAA... phone"]
set -euxo pipefail
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
USER_NAME=yuji
PHONE_KEY="${1:-}"

# Tailscale apt repo (official, signed)
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/resolute.noarmor.gpg \
  -o /usr/share/keyrings/tailscale-archive-keyring.gpg
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/resolute.tailscale-keyring.list \
  -o /etc/apt/sources.list.d/tailscale.list
apt-get update
apt-get install -y openssh-server tailscale tmux

# SSH: keys only, only user yuji, no root
mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/10-phone.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
AllowUsers yuji
EOF
sshd -t
systemctl enable --now ssh
systemctl restart ssh

# Phone public key (optional argument); added once, owned by the user
if [ -n "$PHONE_KEY" ]; then
  case "$PHONE_KEY" in
    ssh-ed25519\ *|ssh-rsa\ *|ecdsa-sha2-*) ;;
    *) echo "that is not a public key (it must start with ssh-ed25519 ...)"; exit 1 ;;
  esac
  install -d -m 700 -o "$USER_NAME" -g "$USER_NAME" "/home/$USER_NAME/.ssh"
  AK="/home/$USER_NAME/.ssh/authorized_keys"
  touch "$AK"
  grep -qxF "$PHONE_KEY" "$AK" || echo "$PHONE_KEY" >> "$AK"
  chown "$USER_NAME:$USER_NAME" "$AK"
  chmod 600 "$AK"
fi

# Tailscale: start the service, then log in (prints a link if not logged in yet)
systemctl enable --now tailscaled
tailscale up

echo
echo "Done. Phone: install Tailscale + an SSH app, connect to $USER_NAME@$(tailscale ip -4 | head -1), then: tmux new -A -s phone"
