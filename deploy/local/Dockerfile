FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        adduser \
        ca-certificates \
        curl \
        fonts-font-awesome \
        fonts-inconsolata \
        fonts-noto-core \
        fonts-roboto-unhinted \
        gsfonts \
        libjs-underscore \
        lsb-base \
        postgresql-client \
        python3 \
        python3-asn1crypto \
        python3-babel \
        python3-cbor2 \
        python3-chardet \
        python3-cryptography \
        python3-dateutil \
        python3-docutils \
        python3-freezegun \
        python3-geoip2 \
        python3-gevent \
        python3-greenlet \
        python3-idna \
        python3-jinja2 \
        python3-libsass \
        python3-lxml \
        python3-lxml-html-clean \
        python3-magic \
        python3-markupsafe \
        python3-num2words \
        python3-ofxparse \
        python3-openpyxl \
        python3-openssl \
        python3-passlib \
        python3-pil \
        python3-polib \
        python3-psutil \
        python3-psycopg2 \
        python3-pypdf \
        python3-qrcode \
        python3-reportlab \
        python3-requests \
        python3-rjsmin \
        python3-rl-renderpm \
        python3-stdnum \
        python3-tz \
        python3-urllib3 \
        python3-vobject \
        python3-werkzeug \
        python3-xlrd \
        python3-xlsxwriter \
        python3-zeep \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --system odoo \
    && useradd --system --gid odoo --home-dir /var/lib/odoo --create-home --shell /bin/bash odoo \
    && mkdir -p /etc/odoo /opt/odoo \
    && chown -R odoo:odoo /etc/odoo /opt/odoo /var/lib/odoo

WORKDIR /opt/odoo

COPY --chown=odoo:odoo . /opt/odoo
COPY deploy/local/entrypoint.sh /usr/local/bin/odoo-local-entrypoint

RUN chmod +x /usr/local/bin/odoo-local-entrypoint

USER odoo

EXPOSE 8069

ENTRYPOINT ["odoo-local-entrypoint"]
CMD ["server"]
