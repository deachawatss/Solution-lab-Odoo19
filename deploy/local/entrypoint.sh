#!/usr/bin/env bash
set -euo pipefail

: "${ODOO_DB_HOST:=db}"
: "${ODOO_DB_PORT:=5432}"
: "${ODOO_DB_USER:?ODOO_DB_USER is required}"
: "${ODOO_DB_PASSWORD:?ODOO_DB_PASSWORD is required}"
: "${ODOO_DB_NAME:=solution_lab_odoo19}"
: "${ODOO_MASTER_PASSWORD:?ODOO_MASTER_PASSWORD is required}"
: "${ODOO_COMPANY_NAME:=Solution Lab}"

cat > /etc/odoo/odoo.conf <<EOF
[options]
admin_passwd = ${ODOO_MASTER_PASSWORD}
data_dir = /var/lib/odoo
db_host = ${ODOO_DB_HOST}
db_port = ${ODOO_DB_PORT}
db_user = ${ODOO_DB_USER}
db_password = ${ODOO_DB_PASSWORD}
http_interface = 0.0.0.0
http_port = 8069
addons_path = /opt/odoo/addons,/opt/odoo/odoo/addons
list_db = True
proxy_mode = False
without_demo = True
EOF

wait_for_postgres() {
  python3 - <<'PY'
import os
import sys
import time

import psycopg2

deadline = time.monotonic() + 120
while time.monotonic() < deadline:
    try:
        conn = psycopg2.connect(
            host=os.environ["ODOO_DB_HOST"],
            port=os.environ["ODOO_DB_PORT"],
            user=os.environ["ODOO_DB_USER"],
            password=os.environ["ODOO_DB_PASSWORD"],
            dbname="postgres",
        )
        conn.close()
        sys.exit(0)
    except psycopg2.Error:
        time.sleep(2)

print("Timed out waiting for PostgreSQL", file=sys.stderr)
sys.exit(1)
PY
}

needs_init() {
  python3 - <<'PY'
import os
import sys

import psycopg2

params = {
    "host": os.environ["ODOO_DB_HOST"],
    "port": os.environ["ODOO_DB_PORT"],
    "user": os.environ["ODOO_DB_USER"],
    "password": os.environ["ODOO_DB_PASSWORD"],
}
dbname = os.environ["ODOO_DB_NAME"]

with psycopg2.connect(dbname="postgres", **params) as conn:
    conn.autocommit = True
    with conn.cursor() as cur:
        cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (dbname,))
        if cur.fetchone() is None:
            sys.exit(0)

try:
    with psycopg2.connect(dbname=dbname, **params) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT 1
                  FROM ir_module_module
                 WHERE name = 'base'
                   AND state = 'installed'
                 LIMIT 1
                """
            )
            sys.exit(1 if cur.fetchone() else 0)
except psycopg2.Error:
    sys.exit(0)
PY
}

if [[ "${1:-server}" == "server" ]]; then
  wait_for_postgres
  if needs_init; then
    python3 /opt/odoo/odoo-bin \
      --config=/etc/odoo/odoo.conf \
      --database="${ODOO_DB_NAME}" \
      --init=base \
      --without-demo=True \
      --stop-after-init
  fi

  ODOO_COMPANY_NAME="${ODOO_COMPANY_NAME}" python3 /opt/odoo/odoo-bin shell \
    --config=/etc/odoo/odoo.conf \
    --database="${ODOO_DB_NAME}" <<'PY'
import os

company = env.ref("base.main_company", raise_if_not_found=False)
if company and company.name != os.environ["ODOO_COMPANY_NAME"]:
    company.write({"name": os.environ["ODOO_COMPANY_NAME"]})
env["ir.config_parameter"].sudo().set_param("web.base.url", "http://localhost:8069")
env.cr.commit()
PY

  exec python3 /opt/odoo/odoo-bin \
    --config=/etc/odoo/odoo.conf \
    --database="${ODOO_DB_NAME}"
fi

exec "$@"
