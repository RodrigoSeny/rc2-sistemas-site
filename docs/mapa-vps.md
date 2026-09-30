# Mapa da VPS — rc2sistemas.cloud

VPS Hostinger `srv1797736` — IP `187.127.43.130` — Ubuntu, Nginx 1.24, PM2.

## Endereços

| Subdomínio | O que é | Como roda | Repositório | Config Nginx |
|---|---|---|---|---|
| `rc2sistemas.cloud`, `www` | Site institucional RC2 Sistemas | **Estático (Nginx)**; demais caminhos repassados ao SuperPet | `rc2-sistemas-site` | `rc2site` |
| `app` | SuperPet (rações / petshop) | PM2 `superpet`, porta 3001 | `RCSystem-Racoes` | `superpet` |
| `cicle` | CicleSystem (bicicletarias) | PM2 `ciclesystem`, porta 3000 | `ciclesystem` | `ciclesystem` |
| `cem` | CEM | PM2 `cem`, porta 3300 | `cem` | `cem` |
| `fiscal` | Comparador Fiscal | Estático (Nginx), /var/www/comparador-fiscal | — | `comparador-fiscal` |
| `contabil` | Site RC2 Contábil + Calculadora do Simples | **Estático (Nginx)** | `rc2-contabil-site` | `rc2-contabil` |

## Regras da divisão

1. **Site público ≠ sistema.** Páginas públicas (institucional, calculadora) são
   estáticas e servidas direto pelo Nginx: não caem quando um sistema reinicia
   e não expõem código de sistema.
2. **Um subdomínio, um repositório, uma pasta, um processo** por sistema.
3. **Portas dos sistemas só internas** (127.0.0.1); acesso externo só via Nginx com HTTPS.
4. **Cada sistema com seu usuário Linux** (em andamento — hoje o PM2 roda como root).
5. **Estatística sem rastreador:** logs de acesso com IP anonimizado em
   `/var/log/nginx-rc2/`, relatório GoAccess protegido por senha em
   `https://rc2sistemas.cloud/estatisticas/`.

## Backups

| Sistema | Como | Quando |
|---|---|---|
| SuperPet | `deploy/backup/backup-superpet.sh` (sqlite3 `.backup`, principal + tenants) → `/var/backups/superpet`, 30 dias | 03:30 (`/etc/cron.d/rc2-backups`) |
| CicleSystem | `/root/backup-ciclesystem.sh` | 03:00 (crontab do root) |
| CEM | `/var/www/cem/backup.sh` | 02:00 (crontab do root) |

**Fora da VPS:** backup automático da Hostinger (hPanel → VPS → Backups), que copia
o servidor inteiro — inclusive `/var/backups/superpet` com os 30 dias de backups
diários. Antes de mudanças arriscadas, tirar um **snapshot** manual no hPanel.

## Atualizar cada coisa

| O quê | Comando na VPS |
|---|---|
| SuperPet | `cd /var/www/superpet && bash update.sh` |
| Site RC2 Sistemas | `bash /var/www/rc2-sistemas-site/deploy/atualizar.sh` |
| Site RC2 Contábil | `bash /var/www/rc2-contabil-site/deploy/atualizar.sh` |
| Estatísticas (manual) | `/var/www/rc2-sistemas-site/deploy/estatisticas/gerar.sh` |

## Futuro

- `controle-contabil` (sistema do escritório, NestJS + Next.js + PostgreSQL):
  subdomínio próprio (ex.: `escritorio.rc2sistemas.cloud`), separado do site
  público `contabil`.
- Domínio próprio da RC2 Contábil (ex.: `rc2contabil.com.br`): só troca de
  `server_name` e certificado no Nginx.
