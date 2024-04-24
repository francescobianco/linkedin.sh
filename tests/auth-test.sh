#!/bin/bash

source .env
source src/auth.sh

mkdir -p tests/tmp

access_token_file="tests/tmp/access_token.json"

#rm -fr "${access_token_file}"

linkedin_auth "${access_token_file}" "${LINKEDIN_CLIENT_ID}" "${LINKEDIN_CLIENT_SECRET}"
