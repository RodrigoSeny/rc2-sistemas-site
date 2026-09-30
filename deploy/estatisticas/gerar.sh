#!/bin/bash
# Gera os relatórios de visitas (GoAccess) do site da RC2 Sistemas e do site da
# RC2 Contábil a partir dos logs anônimos do Nginx (IP com o final zerado).
# Roda de hora em hora pelo cron (ver rc2-estatisticas.cron).
set -euo pipefail

LOGS=/var/log/nginx-rc2
OUT=/var/www/estatisticas
mkdir -p "$OUT"

gerar() {
  local nome="$1" titulo="$2"
  shopt -s nullglob
  local arquivos=("$LOGS/$nome.access.log"*)
  shopt -u nullglob
  [ ${#arquivos[@]} -eq 0 ] && return 0
  # zcat -f lê tanto o log atual quanto os rotacionados (.gz).
  zcat -f "${arquivos[@]}" | goaccess - \
    --log-format=COMBINED \
    --ignore-crawlers \
    --ignore-statics=req \
    --html-report-title="$titulo" \
    --no-progress \
    -o "$OUT/$nome.tmp.html"
  mv -f "$OUT/$nome.tmp.html" "$OUT/$nome.html"
}

gerar sistemas "Visitas — RC2 Sistemas (rc2sistemas.cloud)"
gerar contabil "Visitas — RC2 Contábil (contabil.rc2sistemas.cloud)"

cat > "$OUT/index.html" <<HTML
<!DOCTYPE html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex, nofollow"><title>Estatísticas de visitas</title></head>
<body>
<h1>Estatísticas de visitas</h1>
<ul>
  <li><a href="sistemas.html">RC2 Sistemas — rc2sistemas.cloud</a></li>
  <li><a href="contabil.html">RC2 Contábil — contabil.rc2sistemas.cloud</a></li>
</ul>
<p>Atualizado em $(date '+%d/%m/%Y %H:%M'). Robôs de busca não entram na contagem. IP anonimizado na gravação; logs guardados por cerca de 13 meses.</p>
</body></html>
HTML
