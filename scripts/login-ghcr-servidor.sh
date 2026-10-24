#!/usr/bin/env bash
# Deixa o servidor do Comunique-se baixar a imagem privada do Chatwoot (ghcr.io/stephensonsn/comunique-se-chatwoot).
# Use um token do GitHub "classic" só com o escopo read:packages (https://github.com/settings/tokens/new?scopes=read:packages).
# O token é lido sem aparecer na tela e vai pelo stdin do ssh (fica no /root/.docker/config.json do servidor).
#   bash scripts/login-ghcr-servidor.sh
set -euo pipefail
SERVIDOR=root@187.127.42.179
CHAVE_SSH=~/.ssh/id_ed25519_hostinger

read -r -s -p "Cole o token do GitHub (read:packages) e tecle Enter: " TOKEN; echo
[[ "$TOKEN" =~ ^(ghp_|github_pat_)[A-Za-z0-9_]{20,}$ ]] || { echo "Isso não parece um token do GitHub (ghp_... ou github_pat_...)."; exit 1; }

printf '%s\n' "$TOKEN" | ssh -i "$CHAVE_SSH" "$SERVIDOR" '
  docker login ghcr.io -u stephensonsn --password-stdin >/dev/null && echo "Login no ghcr.io OK"
  docker pull ghcr.io/stephensonsn/comunique-se-chatwoot:v4.18.0-imep.1 2>&1 | tail -1
'
unset TOKEN
