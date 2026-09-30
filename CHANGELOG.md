# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/)
e [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Não lançado]

## [1.1.1] - 2026-09-30

### Alterado
- Envio ao Google Drive desativado no cron: a cópia fora da VPS passa a ser o
  backup automático da Hostinger. Script e guia mantidos para uso futuro.

## [1.1.0] - 2026-09-30

### Adicionado
- Backup fora da VPS: `enviar-nuvem.sh` envia os backups ao Google Drive
  com rclone crypt (conteúdo e nomes cifrados, escopo `drive.file`), retenção
  de 90 dias, às 04:15. Guia em `docs/backup-nuvem.md`.

## [1.0.0] - 2026-09-30

### Adicionado
- Site institucional da RC2 Sistemas como site estático (antes `site-rc2.html`
  dentro do RCSystem-Racoes). CSS e JS em arquivos próprios (CSP sem inline),
  logo otimizada de 1 MB para 37 KB.
- Estatísticas de visitas com GoAccess sobre logs anônimos do Nginx (RC2
  Sistemas e RC2 Contábil), retenção de ~13 meses, relatório protegido por senha.
- `docs/mapa-vps.md`: divisão da VPS por subdomínio, backups e regras.
- Backup diário consistente (sqlite3 `.backup` + verificação de integridade)
  dos bancos do SuperPet, incluindo os bancos das contas (tenants).
- `docs/runbook-usuarios.md`: roteiro para rodar cada sistema com usuário próprio.
