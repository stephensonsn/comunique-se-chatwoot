# Chatwoot do Comunique-se (IMEP)

Imagem do Chatwoot usada em `chat.comunique-se.io`: a **versão oficial CE** + os patches da IMEP.
Não é fork: este repositório guarda só a versão, os patches e o pipeline.

| Arquivo | Para quê |
|---|---|
| `CHATWOOT_VERSION` | versão oficial do Chatwoot (tag) |
| `patches/*.patch` | mudanças da IMEP, aplicadas em ordem |
| `scripts/aplicar.sh` | clona a versão e aplica os patches (local e CI) |
| `.github/workflows/imagem.yml` | PR: confere; `main`: publica `ghcr.io/stephensonsn/comunique-se-chatwoot:<versão>-imep.<n>` |
| `.github/workflows/nova-versao.yml` | toda segunda abre PR quando sai versão nova |

## Patches

### 0001 — Assinatura: no começo ou no fim, com ou sem `--`

- **Conta** (Configurações → Conta → "Assinatura das mensagens", só administrador): padrão da conta
  (no começo / no fim, com ou sem `--`) e **"Bloquear alteração pelos atendentes"**.
  Grava em `accounts.settings`: `signature_position` (`start`|`end`), `signature_delimiter`, `signature_locked`.
- **Atendente** (Perfil → Assinatura): as mesmas opções em `ui_settings`; desabilitadas se a conta bloquear.
- **Regra**: conta bloqueada → conta; senão → atendente; sem escolha → padrão da conta; sem padrão →
  original (fim com `--`).
- **No começo**: `**Nome:**` num parágrafo próprio e depois a mensagem; no WhatsApp chega como
  `*Nome:*` + quebra de linha + mensagem. O nome sai como foi digitado.
- Arquivos: `helper/editorHelper.js` (núcleo), `App.vue` (aplica as opções), telas de perfil e conta,
  `imepSignatureTexts.js` (textos fora dos arquivos de tradução, para não conflitar), backend da conta
  (`account.rb`, `accounts_controller.rb`, `account_settings_schema.rb`). Testes:
  `helper/specs/editorHelperSignatureImep.spec.js`.

## Atualizar o Chatwoot

1. Esperar o PR automático (ou trocar `CHATWOOT_VERSION` e abrir PR).
2. CI verde = patches encaixam e testes passam → merge → imagem nova no GHCR.
3. CI vermelho = o Chatwoot mudou onde o patch mexe: `scripts/aplicar.sh`, resolver, gerar o patch de novo
   (`git -C chatwoot diff > patches/…`), subir no PR.
4. No servidor: backup do banco, trocar a tag em `/opt/comunique-se/chatwoot/docker-compose.yml`,
   `docker compose up -d`. Voltar = tag anterior.

## Gerar o patch de novo (depois de mexer em `chatwoot/`)

```bash
cd chatwoot && git add -A -- app && git diff --cached --binary > ../patches/0001-assinatura-posicao-separador.patch && git reset -q
```
