#!/bin/bash

source .env
source src/auth.sh
source src/info.sh
source src/post.sh
source src/util.sh

mkdir -p tests/tmp

access_token_file="tests/tmp/access_token.json"
post_file="tests/fixtures/post.txt"

#rm -fr "${access_token_file}"

linkedin_auth "${access_token_file}" "${LINKEDIN_CLIENT_ID}" "${LINKEDIN_CLIENT_SECRET}"
linkedin_post "${access_token_file}" "${post_file}"
