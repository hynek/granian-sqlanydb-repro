# Use non-Apple bash so LD_* is not filtered.
set shell := ["/usr/local/bin/bash", "-c"]

PORT := "8888"
PROJECT := file_name(invocation_directory())

@_:
    just --list


serve-flask:
    uv run flask -A repro.app run --port {{ PORT }}

serve:
    uv run granian --interface wsgi --port {{ PORT }} repro.app

req path="":
    curl 127.0.0.1:{{ PORT }}/{{ path }}

req-break-it:
    just req break-it

update:
    uv lock --upgrade


docker-build *extra:
    docker build \
        {{ extra }} \
        --platform=linux/amd64 \
        --pull \
        --progress=plain \
        --tag example.com/{{ PROJECT }}:local \
        .

alias dr := docker-run

docker-run entrypoint="/docker-entrypoint.sh": docker-build
    docker run \
        --platform=linux/amd64 \
        --init \
        --name "repro" \
        --entrypoint {{ entrypoint }}  \
        -p {{PORT}}:8000 \
        --rm \
        -it \
        example.com/{{ PROJECT }}:local


alias de := docker-enter

docker-enter:
    docker exec -it -u root repro bash

docker-stop:
    docker stop repro

