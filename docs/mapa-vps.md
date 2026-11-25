# Mapa da VPS — rc2sistemas.cloud

VPS Hostinger `srv1797736` — IP `187.127.43.130` — Ubuntu, Nginx 1.24, PM2.

## Endereços

| Subdomínio | O que é | Como roda | Repositório | Config Nginx |
|---|---|---|---|---|
| `rc2sistemas.cloud`, `www` | Site institucional RC2 Sistemas | **Estático (Nginx)**; /calculadora* → calculadora da RC2 Contábil; demais caminhos → RC2Pet (redirecionamento) | `rc2-sistemas-site` | `rc2site` |
| `app` | **Desativado em 24/11/2026** (era o SuperPet): só redireciona para o RC2Pet. Cópia final em `C:Projetosackupssuperpet` (PC do Rodrigo) | Nginx (redirecionamento) | `RCSystem-Racoes` (arquivado) | `superpet` |
| `cicle` | CicleSystem (bicicletarias) | PM2 `ciclesystem`, porta 3000, banco PostgreSQL local (só 127.0.0.1), usuário `cicle` ✅ | `ciclesystem` | `ciclesystem` |
| `cem` | CEM | PM2 `cem`, porta 3300, usuário `cem` ✅ | `cem` | `cem` |
| `financas` | Finanças (SaaS de finanças pessoais) | PM2 `financas`, porta 3400, PostgreSQL local (banco `financas`, só 127.0.0.1), usuário `financas` ✅ | `Financeiro-Pessoal` (git na VPS: `/srv/git/financas.git`) | `financas` |
| `pet` | RC2Pet (novo sistema da Super Pet / pet shops, SaaS multi-loja) | PM2 `rc2pet` (cluster, 1 instância), porta 3600, PostgreSQL local (banco `rc2pet`, só 127.0.0.1), usuário `rc2pet` ✅ | `RC2Pet` (git na VPS: `/srv/git/rc2pet.git`; GitHub privado RodrigoSeny/RC2Pet) | `rc2pet` |
| `fiscal` | Comparador Fiscal | Estático (Nginx), /var/www/comparador-fiscal | — | `comparador-fiscal` |
| `contabil` | Site RC2 Contábil + Calculadora do Simples | **Estático (Nginx)** | `rc2-contabil-site` | `rc2-contabil` |
| `centralpark` | Piloto financeiro Central Park (demonstração para a cliente, noindex) | **Estático (Nginx)**, /var/www/centralpark-piloto | `crematorio-central-park` (apps/piloto, publicar com `deploy/publicar.sh`) | `centralpark` |

## Regras da divisão

1. **Site público ≠ sistema.** Páginas públicas (institucional, calculadora) são
   estáticas e servidas direto pelo Nginx: não caem quando um sistema reinicia
   e não expõem código de sistema.
2. **Um subdomínio, um repositório, uma pasta, um processo** por sistema.
3. **Firewall (ufw) ativo** desde 2026-09-30: entrada liberada só em 22 (SSH), 80 e 443.
   Portas dos sistemas (3000, 3300, 3400, 3500, 3501, 3600) bloqueadas para fora; acesso só via Nginx com HTTPS.
4. **Cada sistema com seu usuário Linux**, sem senha e sem login: `cem` ✅, `cicle` ✅,
   `rc2pet` ✅, `financas` ✅. O código fica com dono root (só leitura para o sistema);
   o usuário do sistema só escreve nas pastas de dados, uploads e logs.
5. **Estatística sem rastreador:** logs de acesso com IP anonimizado em
   `/var/log/nginx-rc2/`, relatório GoAccess protegido por senha em
   `https://rc2sistemas.cloud/estatisticas/`.

## Backups

| Sistema | Como | Quando |
|---|---|---|
| CicleSystem | `/root/backup-ciclesystem.sh` | 03:00 (crontab do root) |
| CEM | `/var/www/cem/backup.sh` | 02:00 (crontab do root) |
| Finanças | `/var/www/financas/deploy/backup.sh` (pg_dump → `/var/backups/financas`, 30 dias; restauração testada) | 03:15 (`/etc/cron.d/rc2-backups`) |
| RC2Pet | `/var/www/rc2pet/deploy/backup.sh` (pg_dump → `/var/backups/rc2pet-db`, 30 dias) + cópia JSON do próprio sistema em `/var/backups/rc2pet` (14 dias) | 04:00 (`/etc/cron.d/rc2-backups`) |

**Fora da VPS:** backup automático da Hostinger (hPanel → VPS → Backups), que copia
o servidor inteiro, inclusive as pastas de backup acima. Antes de mudanças arriscadas, tirar um **snapshot** manual no hPanel.

## Atualizar cada coisa

| O quê | Comando na VPS |
|---|---|
| Finanças | (no PC) `git push vps main` → (na VPS) `bash /var/www/financas/deploy/update.sh` |
| RC2Pet | (no PC) `git push vps main` → (na VPS) `bash /var/www/rc2pet/deploy/update.sh` |
| Site RC2 Sistemas | `bash /var/www/rc2-sistemas-site/deploy/atualizar.sh` |
| Site RC2 Contábil | `bash /var/www/rc2-contabil-site/deploy/atualizar.sh` |
| Estatísticas (manual) | `/var/www/rc2-sistemas-site/deploy/estatisticas/gerar.sh` |

## Futuro

- `controle-contabil` (sistema do escritório, NestJS + Next.js + PostgreSQL):
  subdomínio próprio (ex.: `escritorio.rc2sistemas.cloud`), separado do site
  público `contabil`.
- Domínio próprio da RC2 Contábil (ex.: `rc2contabil.com.br`): só troca de
  `server_name` e certificado no Nginx.
