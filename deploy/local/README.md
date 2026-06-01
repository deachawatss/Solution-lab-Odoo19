# Solution Lab Odoo 19 Local Runtime

Local Docker runtime for the Solution Lab Odoo 19 customization branch.

## Start

```bash
cp deploy/local/env.example deploy/local/.env
docker compose -f deploy/local/compose.yml up -d --build
```

The local `.env` file is intentionally ignored. Set local credentials there.

## Runtime

- Odoo: `http://localhost:8069`
- Public URL: `https://odoo.solutionlabth.com`
- Database: `solution_lab_odoo19`
- Postgres image: `postgres:latest`
- Company: `Solution Lab`
- Demo data: disabled

## Cloudflare Tunnel

Use a Cloudflare Tunnel for `odoo.solutionlabth.com` so Odoo does not need an inbound public port.

1. In Cloudflare Zero Trust, create a tunnel named `solution-lab-odoo19`.
2. Add a public hostname:
   - Hostname: `odoo.solutionlabth.com`
   - Service: `http://odoo:8069`
3. Paste the tunnel token into `deploy/local/.env`:

```bash
TUNNEL_TOKEN=...
```

4. Start the tunnel connector:

```bash
docker compose --profile cloudflare -f deploy/local/compose.yml up -d cloudflared
```

The Odoo container is already configured with `proxy_mode = True` and `web.base.url = https://odoo.solutionlabth.com`.
