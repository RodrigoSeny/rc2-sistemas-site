# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/)
e [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Não lançado]

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
