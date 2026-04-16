# syntax=docker/dockerfile:1.7

ARG FRAPPE_BRANCH=version-16
ARG FRAPPE_PATH=https://github.com/frappe/frappe

FROM frappe/build:${FRAPPE_BRANCH} AS builder

ARG FRAPPE_BRANCH
ARG FRAPPE_PATH

USER frappe

RUN --mount=type=secret,id=apps_json,dst=/tmp/apps.json \
    bench init --apps_path=/tmp/apps.json \
      --frappe-branch=${FRAPPE_BRANCH} \
      --frappe-path=${FRAPPE_PATH} \
      --no-procfile \
      --no-backups \
      --skip-redis-config-generation \
      --verbose \
      /home/frappe/frappe-bench && \
    cd /home/frappe/frappe-bench && \
    echo "{}" > sites/common_site_config.json && \
    find apps -mindepth 1 -path "*/.git" | xargs rm -fr

FROM frappe/base:${FRAPPE_BRANCH}

LABEL org.opencontainers.image.source="https://github.com/RafaLeme/frappe-suite-image"

USER frappe
COPY --from=builder --chown=frappe:frappe /home/frappe/frappe-bench /home/frappe/frappe-bench

WORKDIR /home/frappe/frappe-bench

VOLUME ["/home/frappe/frappe-bench/sites", "/home/frappe/frappe-bench/sites/assets", "/home/frappe/frappe-bench/logs"]

CMD ["/home/frappe/frappe-bench/env/bin/gunicorn", "--chdir=/home/frappe/frappe-bench/sites", "--bind=0.0.0.0:8000", "--threads=4", "--workers=2", "--worker-class=gthread", "--worker-tmp-dir=/dev/shm", "--timeout=120", "--preload", "frappe.app:application"]
