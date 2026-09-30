#!/bin/bash
# Atualiza o site da RC2 Sistemas e a infraestrutura (Nginx, backup,
# estatísticas) na VPS — rodar após git push.
# Os scripts já vêm executáveis do repositório (modo 755 gravado no git).
set -e
cd /var/www/rc2-sistemas-site
git pull --ff-only origin main
git fetch -q --tags origin
# As configurações do Nginx incluem arquivos deste repositório: recarrega.
nginx -t && systemctl reload nginx
echo "✅ Site RC2 Sistemas atualizado — versão $(git describe --tags --always)."
