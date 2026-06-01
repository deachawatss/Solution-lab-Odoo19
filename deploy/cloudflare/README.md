# Cloudflare for Solution Lab Odoo 19

Public hostname: `https://odoo.solutionlabth.com`

## Recommended Setup

Use a remotely managed Cloudflare Tunnel from the Cloudflare Zero Trust dashboard.

1. Create a tunnel named `solution-lab-odoo19`.
2. Choose the Docker connector and copy the tunnel token.
3. Add a public hostname:
   - Subdomain: `odoo`
   - Domain: `solutionlabth.com`
   - Service: `http://odoo:8069`
4. Add the token to `deploy/local/.env`:

```bash
TUNNEL_TOKEN=...
```

5. Start the connector:

```bash
docker compose --profile cloudflare -f deploy/local/compose.yml up -d cloudflared
```

Check the connector:

```bash
docker compose --profile cloudflare -f deploy/local/compose.yml logs -f cloudflared
```

## Local CLI Alternative

If `cloudflared` is installed on the host, a locally managed tunnel can be created with:

```bash
cloudflared tunnel login
cloudflared tunnel create solution-lab-odoo19
cloudflared tunnel route dns solution-lab-odoo19 odoo.solutionlabth.com
```

Use this ingress config for host-run `cloudflared`:

```yaml
tunnel: solution-lab-odoo19
credentials-file: /home/deachawat/.cloudflared/<tunnel-id>.json

ingress:
  - hostname: odoo.solutionlabth.com
    service: http://localhost:8069
  - service: http_status:404
```

Then run:

```bash
cloudflared tunnel run solution-lab-odoo19
```
