#!/usr/bin/env bash
# Clona o Chatwoot na versão de CHATWOOT_VERSION e aplica patches/*.patch.
# Falha (exit != 0) se algum patch não encaixar — o pipeline para e o servidor
# continua na imagem anterior.
#
#   scripts/aplicar.sh [pasta]   (padrão: ./chatwoot)
set -euo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
VERSAO="$(tr -d '[:space:]' < "$RAIZ/CHATWOOT_VERSION")"
DESTINO="${1:-$RAIZ/chatwoot}"

if [ ! -d "$DESTINO/.git" ]; then
  git clone --quiet --depth 1 --branch "$VERSAO" https://github.com/chatwoot/chatwoot.git "$DESTINO"
fi
cd "$DESTINO"
for p in "$RAIZ"/patches/*.patch; do
  echo "aplicando $(basename "$p") em $VERSAO"
  git apply --3way --whitespace=nowarn "$p"
done
echo "patches aplicados em $DESTINO"
