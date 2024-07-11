#!/bin/bash

source .env

export LINKEDIN_CLIENT_ID
export LINKEDIN_CLIENT_SECRET

mkdir -p tests/tmp

mush run -- github francescobianco/linkedin-feed
