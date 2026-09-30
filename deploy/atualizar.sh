#!/bin/bash
# Atualiza o site da RC2 Sistemas na VPS — rodar após git push.
# Site estático: basta puxar o código; não há processo para reiniciar.
set -e
cd /var/www/rc2-sistemas-site
git pull --ff-only origin main
git fetch -q --tags origin
chmod 755 deploy/estatisticas/gerar.sh
echo "✅ Site RC2 Sistemas atualizado — versão $(git describe --tags --always)."
