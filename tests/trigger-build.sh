#!/usr/bin/env bash

curl -X POST "${CDURL}" -H "content-type: application/json" -d '{ "secret_key": "'"${SECRET_KEY}"'" }'
