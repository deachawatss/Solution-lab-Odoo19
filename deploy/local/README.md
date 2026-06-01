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
- Database: `solution_lab_odoo19`
- Postgres image: `postgres:latest`
- Company: `Solution Lab`
- Demo data: disabled
