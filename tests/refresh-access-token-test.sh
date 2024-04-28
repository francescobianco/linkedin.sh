#!/bin/bash

source .env
source src/auth.sh
source src/util.sh

mkdir -p tests/tmp

access_token_file="tests/tmp/access_token.json"

#rm -fr "${access_token_file}"

linkedin_auth "${LINKEDIN_CLIENT_ID}" "${LINKEDIN_CLIENT_SECRET}" "${access_token_file}"
