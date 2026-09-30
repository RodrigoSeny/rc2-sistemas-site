# Roteiro — cada sistema com seu próprio usuário Linux

> **Estado (2026-09-30):** os três migrados — `cem` ✅, `cicle` ✅, `superpet` ✅. Nenhum sistema roda mais como root.
>
> **Abordagem usada (mais segura que a descrita abaixo):** o código continua com
> dono `root` (o sistema só lê — não consegue alterar o próprio código); o
> usuário do sistema recebe escrita **só** nas pastas que grava; `.env` fica
> `root:<usuario>` 640. Assim `git pull`/`update.sh` como root seguem iguais.
>
> | Sistema | Pastas com escrita | Observações |
> |---|---|---|
> | cem | `dados/`, `uploads/`, `/var/log/cem` | ecosystem.config.js + `--uid cem --gid cem` |
> | ciclesystem | `dados/`, `imagens/`, `/var/log/ciclesystem` | sem ecosystem; `node_modules` precisou de `chmod -R go+rX`; logs saíram de /root/.pm2/logs |
> | superpet | `data/`, `dados/`, `imagens/`, `backups/`, `/var/log/superpet` | ecosystem.config.js |

**Hoje:** os três sistemas (superpet, ciclesystem, cem) rodam como `root` no
PM2 (`pm2-root.service`). Uma falha de segurança em qualquer um deles dá
controle total da VPS e acesso aos dados dos outros.

**Depois:** cada sistema roda com um usuário próprio, sem senha e sem login
(`nologin`). Uma invasão fica restrita à pasta daquele sistema.

O daemon do PM2 continua sendo o `pm2-root` (os comandos `pm2 ...` seguem como
root); só os **processos** dos sistemas passam a rodar com o usuário próprio,
via `--uid/--gid`.

| Sistema | Usuário | Pasta | Porta | Logs |
|---|---|---|---|---|
| cem | `cem` | /var/www/cem | 3300 | ver `pm2 describe cem` |
| ciclesystem | `cicle` | /var/www/ciclesystem | 3000 | /root/.pm2/logs → passa a /var/log/ciclesystem |
| superpet | `superpet` | /var/www/superpet | 3001 | /var/log/superpet |

**Ordem:** cem → ciclesystem → superpet (o PDV por último, fora do horário de
vendas). **Um sistema por vez**, confirmando que está funcionando antes do próximo.

---

## 0. Antes de começar (uma vez)

```bash
pm2 save --force
cp /root/.pm2/dump.pm2 /root/pm2-dump-antes-usuarios.pm2      # volta atrás completa
chmod 600 /root/pm2-dump-antes-usuarios.pm2
```

## 1. Para cada sistema (exemplo: cem)

Troque `APP`, `USR` e `DIR` conforme a tabela.

```bash
APP=cem; USR=cem; DIR=/var/www/cem

# 1.1 Ver como o processo foi iniciado (script, variáveis além do .env)
pm2 describe $APP | grep -E "script path|exec cwd|exec mode|interpreter args|out log path|error log path"
# variáveis de ambiente do processo (só os NOMES; valores podem ser segredos)
pm2 env $(pm2 id $APP | tr -dc '0-9') | grep -oE '^[A-Z][A-Z0-9_]*:' \
  | grep -vE '^(PATH|HOME|PWD|SHELL|USER|LOGNAME|LANG|LANGUAGE|TERM|SHLVL|MAIL|INVOCATION_ID|JOURNAL_STREAM|SYSTEMD_EXEC_PID|NODE_APP_INSTANCE|PM2_[A-Z_]*):'
grep -oE '^[A-Z][A-Z0-9_]*=' "$DIR/.env" 2>/dev/null   # compare com o que está no .env
```

> Se aparecer alguma variável que **não** está no `.env` do sistema, anote:
> ela precisa ser repassada no `pm2 start` do passo 1.4.

```bash
# 1.2 Criar o usuário de sistema (sem senha, sem login)
useradd --system --home-dir "$DIR" --no-create-home --shell /usr/sbin/nologin "$USR"

# 1.3 Dar a pasta (e os logs) ao usuário; root continua podendo usar git nela
chown -R "$USR":"$USR" "$DIR"
git config --system --add safe.directory "$DIR"
# (superpet)  chown -R superpet:superpet /var/log/superpet
# (cicle)     mkdir -p /var/log/ciclesystem && chown cicle:cicle /var/log/ciclesystem

# 1.4 Reiniciar o processo com o novo usuário
pm2 delete $APP
cd "$DIR"
#   cem / superpet (têm ecosystem.config.js):
pm2 start ecosystem.config.js --only $APP --uid "$USR" --gid "$USR"
#   ciclesystem (sem ecosystem): ajuste conforme o passo 1.1
#   pm2 start server.js --name ciclesystem --uid cicle --gid cicle \
#       -o /var/log/ciclesystem/out.log -e /var/log/ciclesystem/error.log

# 1.5 Conferir
sleep 3
pm2 ls
ps -o user=,pid=,cmd= -p "$(pm2 pid $APP | head -1)"     # deve mostrar o USR, não root
pm2 logs $APP --lines 30 --nostream                        # sem erro de permissão (EACCES)
curl -sI http://127.0.0.1:PORTA/ | head -1                 # troque PORTA

# 1.6 Se estiver tudo ok, gravar
pm2 save --force
```

Depois, teste pelo navegador (login, uma operação que grave dado, upload de
imagem se o sistema tiver).

### Se der errado (volta atrás daquele sistema)

```bash
pm2 delete $APP
chown -R root:root "$DIR"
cd "$DIR" && pm2 start ecosystem.config.js --only $APP     # ou o comando original
pm2 save --force
```

Volta atrás completa (todos): `pm2 kill && cp /root/pm2-dump-antes-usuarios.pm2 /root/.pm2/dump.pm2 && pm2 resurrect`.

## 2. Depois de migrar

- `update.sh` do superpet (v2.6.0+) devolve a posse da pasta ao usuário do
  sistema depois do `git pull`/`npm install` feitos como root.
- CEM e CicleSystem: após cada atualização feita como root, rodar
  `chown -R USR:USR /var/www/APP`.
- Os crons de backup continuam como root (precisam ler todos os bancos).
