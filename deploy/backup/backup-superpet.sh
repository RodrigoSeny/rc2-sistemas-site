#!/bin/bash
# Backup diário dos bancos SQLite do SuperPet (principal + contas/tenants).
#
# Usa o comando ".backup" do sqlite3, que gera cópia consistente mesmo com o
# sistema rodando (copiar o arquivo .db "na mão" com o sistema aberto pode
# gerar cópia corrompida). Compacta e guarda 30 dias em /var/backups/superpet.
#
# Agendado por deploy/backup/rc2-backups.cron. Requer: apt install sqlite3
set -euo pipefail

APP=/var/www/superpet
DEST_RAIZ=/var/backups/superpet
RETENCAO_DIAS=30
DIA=$(date +%F)
DEST="$DEST_RAIZ/$DIA"

mkdir -p "$DEST"
chmod 700 "$DEST_RAIZ"

shopt -s nullglob
bancos=("$APP"/data/*.db "$APP"/dados/*.db "$APP"/*.db)
shopt -u nullglob

total=0
for db in "${bancos[@]}"; do
  [ -s "$db" ] || continue
  origem=$(basename "$(dirname "$db")")
  nome="${origem}__$(basename "$db" .db)"
  sqlite3 "$db" ".timeout 20000" ".backup '$DEST/$nome.db'"
  # Confere a integridade da cópia antes de compactar.
  if [ "$(sqlite3 "$DEST/$nome.db" 'PRAGMA integrity_check;')" != "ok" ]; then
    echo "$(date '+%F %T') ERRO: integridade falhou em $db" >&2
    exit 1
  fi
  gzip -f "$DEST/$nome.db"
  total=$((total + 1))
  # Este script roda como root. Se o SuperPet roda com usuário próprio, os
  # arquivos auxiliares do SQLite (-wal/-shm/-journal) que o root venha a criar
  # precisam voltar para o dono do banco — senão o sistema perde a escrita.
  dono=$(stat -c %U:%G "$db")
  for aux in "$db-wal" "$db-shm" "$db-journal"; do
    [ -e "$aux" ] && chown "$dono" "$aux"
  done
done

# Remove backups mais antigos que a retenção.
find "$DEST_RAIZ" -mindepth 1 -maxdepth 1 -type d -mtime +"$RETENCAO_DIAS" -exec rm -rf {} +

echo "$(date '+%F %T') OK: $total banco(s) em $DEST ($(du -sh "$DEST" | cut -f1))"
