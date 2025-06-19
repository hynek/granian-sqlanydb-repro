#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

. /opt/sqlanywhere17/bin64/sa_config.sh

exec 2>&1 \
    /app/bin/granian \
        --interface wsgi \
        --host 0.0.0.0 \
        repro.app
