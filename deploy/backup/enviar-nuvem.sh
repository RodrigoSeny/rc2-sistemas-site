#!/bin/bash
# Envia os backups locais da VPS para o Google Drive, CRIPTOGRAFADOS (rclone crypt).
#
# Pastas enviadas: /etc/rc2-backups-nuvem.list, uma por linha no formato
#   nome=/caminho/da/pasta
# (ex.: superpet=/var/backups/superpet). Cada uma vai para
#   <remote>/<nome>/  no Drive, com os nomes dos arquivos também cifrados.
#
# Só ACRESCENTA arquivos no Drive (rclone copy): apagar algo na VPS não apaga
# a cópia na nuvem. Arquivos com mais de RETENCAO_DIAS são removidos do Drive.
#
# Agendado por deploy/backup/rc2-backups.cron (04:15, depois de todos os backups).
set -euo pipefail

REMOTE="${RC2_BACKUP_REMOTE:-gdrive-cripto:}"
LISTA="${RC2_BACKUP_LISTA:-/etc/rc2-backups-nuvem.list}"
RETENCAO_DIAS=90

[ -f "$LISTA" ] || { echo "$(date '+%F %T') ERRO: $LISTA não existe" >&2; exit 1; }

falhas=0
while IFS="=" read -r nome pasta || [ -n "$nome" ]; do
  nome="${nome// /}"; pasta="${pasta## }"
  [[ -z "$nome" || "$nome" == \#* ]] && continue
  if [ ! -d "$pasta" ]; then
    echo "$(date '+%F %T') AVISO: $nome — pasta $pasta não existe, pulando" >&2
    continue
  fi
  if rclone copy "$pasta" "${REMOTE}${nome}" --transfers 2 --checkers 4 --retries 3 --low-level-retries 5; then
    rclone delete "${REMOTE}${nome}" --min-age "${RETENCAO_DIAS}d" || true
    rclone rmdirs "${REMOTE}${nome}" --leave-root || true
    echo "$(date '+%F %T') OK: $nome ($pasta)"
  else
    echo "$(date '+%F %T') ERRO: falha ao enviar $nome ($pasta)" >&2
    falhas=$((falhas + 1))
  fi
done < "$LISTA"

exit "$falhas"
