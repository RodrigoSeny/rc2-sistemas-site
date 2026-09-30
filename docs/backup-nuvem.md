# Backup fora da VPS — Google Drive (criptografado)

> **DESATIVADO (2026-09-30).** Optou-se pelo backup automático da Hostinger.
> Este envio fica pronto para ser ativado depois. Para ativar: criar um
> client_id próprio no Google Cloud (o client_id compartilhado do rclone deixa
> de funcionar em 2026), configurar os remotes `gdrive` e `gdrive-cripto` e
> acrescentar ao `/etc/cron.d/rc2-backups`:
> `15 4 * * * root /var/www/rc2-sistemas-site/deploy/backup/enviar-nuvem.sh >> /var/log/backup-nuvem.log 2>&1`

Os backups locais (`/var/backups/superpet`, CEM, CicleSystem) ficam no mesmo
disco da VPS. Todo dia às 04:15, `deploy/backup/enviar-nuvem.sh` envia uma
cópia **criptografada** para o Google Drive.

- **Criptografia:** rclone `crypt`. Conteúdo **e nomes** dos arquivos são
  cifrados; no Drive aparecem só nomes embaralhados na pasta `RC2-Backups-VPS`.
- **Acesso mínimo:** o rclone usa o escopo `drive.file`, então só enxerga o
  que ele próprio criou; não tem acesso ao resto do Drive.
- **Retenção no Drive:** 90 dias.
- **Senha da criptografia:** fica na VPS (`/root/.config/rclone/rclone.conf`)
  e **precisa estar guardada também fora dela** (gerenciador de senhas). Se a
  VPS for perdida e a senha também, os backups do Drive **não podem ser abertos**.

## Restaurar (de qualquer máquina com rclone)

```bash
rclone ls gdrive-cripto:superpet | tail                      # lista o que existe
rclone copy gdrive-cripto:superpet/AAAA-MM-DD ./restauracao  # baixa um dia
gunzip ./restauracao/*.gz
sqlite3 ./restauracao/data__contas_pagar.db "PRAGMA integrity_check;"   # deve dizer ok
```

Em outra máquina, recrie os remotes com o **mesmo** token do Google e as
**mesmas** senhas da criptografia (`password` e `password2`).

## Conferir se está funcionando

```bash
tail -n 20 /var/log/backup-nuvem.log
rclone lsd gdrive-cripto:
```
