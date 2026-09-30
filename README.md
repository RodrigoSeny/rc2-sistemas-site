# RC2 Sistemas — site institucional e infraestrutura pública

Site institucional em **https://rc2sistemas.cloud** e os arquivos de
infraestrutura compartilhada da VPS (Nginx, estatísticas de visitas).
Mapa completo da VPS: [`docs/mapa-vps.md`](docs/mapa-vps.md).

O site é estático e servido direto pelo Nginx. Antes ficava dentro do sistema
SuperPet (`RCSystem-Racoes`, arquivo `site-rc2.html`); saiu de lá para não
cair junto quando o sistema reinicia.

## Estrutura

```
public/                      ← raiz servida pelo Nginx em rc2sistemas.cloud
├── index.html
├── robots.txt
└── site/                    ← prefixo próprio, para não colidir com caminhos do SuperPet
    ├── css/site.css
    ├── js/site.js
    └── img/ (rc2-logo.png, rc2-hero-bg.jpg)
deploy/
├── atualizar.sh             ← git pull na VPS
├── nginx/
│   ├── rc2site.conf         ← virtual host de rc2sistemas.cloud (substitui sites-available/rc2site)
│   ├── rc2site-headers.conf ← cabeçalhos de segurança do site (incluído pelo rc2site.conf)
│   └── estatisticas-headers.conf
├── backup/
│   ├── backup-superpet.sh   ← backup diário dos bancos do SuperPet
│   └── rc2-backups.cron
└── estatisticas/
    ├── gerar.sh             ← relatórios GoAccess (RC2 Sistemas e RC2 Contábil)
    ├── rc2-estatisticas.cron
    └── nginx-rc2.logrotate  ← retenção de ~13 meses dos logs anônimos
docs/
├── mapa-vps.md
└── runbook-usuarios.md      ← roteiro: cada sistema com seu usuário Linux
```

## Atualizar

```bash
bash /var/www/rc2-sistemas-site/deploy/atualizar.sh
```
