# syntax=docker/dockerfile:1.9
FROM ubuntu:noble AS build
SHELL ["sh", "-exc"]

ENV DEBIAN_FRONTEND=noninteractive

COPY client17011 /tmp/sqlany
WORKDIR /tmp/sqlany
RUN ./setup -ss -nogui -I_accept_the_license_agreement

RUN <<EOT
apt-get update
apt-get install -qyy \
    -o APT::Install-Recommends=false \
    -o APT::Install-Suggests=false \
    ca-certificates \
    python3.12-dev
EOT

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=/usr/bin/python3.12 \
    UV_PROJECT_ENVIRONMENT=/app

RUN --mount=type=cache,target=/root/.cache \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync \
        --locked \
        --no-dev \
        --no-install-project

COPY . /src
WORKDIR /src
RUN --mount=type=cache,target=/root/.cache \
    uv sync \
        --no-dev \
        --no-editable

##########################################################################

FROM ubuntu:noble
SHELL ["sh", "-exc"]

STOPSIGNAL SIGINT

RUN <<EOT
groupadd -r app
useradd -r -d /app -g app -N app
EOT

ENTRYPOINT ["/docker-entrypoint.sh"]

COPY --from=build /opt/sqlanywhere17/ /opt/sqlanywhere17/
RUN <<EOT
apt-get update
apt-get install -qyy \
    -o APT::Install-Recommends=false \
    -o APT::Install-Suggests=false \
    curl \
    net-tools \
    python3.12
EOT

COPY docker-entrypoint.sh /
COPY --from=build --chown=app:app /app /app

USER app
WORKDIR /app


RUN <<EOT
/app/bin/python -V
/app/bin/python -Im site
/app/bin/python -Ic "import repro"
EOT
