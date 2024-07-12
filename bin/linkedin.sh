#!/usr/bin/env bash
# @BP010: Release metadata
# @package: linkedin.sh
# @build_type: bin
# @build_with: Mush 0.2.0 (2024-03-21)
# @build_date: 2024-07-12T01:36:15Z
set -e
use() { return 0; }
extern() { return 0; }
legacy() { return 0; }
module() { return 0; }
public() { return 0; }
embed() { return 0; }
## BP004: Compile the entrypoint

module auth
module github
module info
module post
module util

usage() {
  echo "Usage: linkedin.sh [COMMAND] [OPTIONS]"
  echo ""
  echo "Available commands"
  echo "  post POSTFILE       Post content of POSTFILE to LinkedIn"
  echo "  github USER/REPO    Activate GitHub repository USER/REPO to post to LinkedIn"
}

main() {
  local command
  local access_token
  local access_token_file
  local client_id
  local client_secret

  command=$1
  client_id="${LINKEDIN_CLIENT_ID}"
  client_secret="${LINKEDIN_CLIENT_SECRET}"
  access_token="${LINKEDIN_ACCESS_TOKEN}"
  access_token_file="${HOME}/.linkedin/access_token.json"

  case $command in
    --help|-h)
      usage
      ;;
    post)
      linkedin_auth "${client_id}" "${client_secret}" "${access_token_file}" "${access_token}"
      linkedin_post "${access_token_file}" "${access_token}" "$2"
      ;;
    info)
      linkedin_auth "${client_id}" "${client_secret}" "${access_token_file}" "${access_token}"
      linkedin_info "${access_token_file}" "${access_token}"
      ;;
    refresh-access-token)
      linkedin_auth "${client_id}" "${client_secret}" "${access_token_file}" "${access_token}"
      ;;
    github)
      linkedin_auth "${client_id}" "${client_secret}" "${access_token_file}" "${access_token}"
      linkedin_github "${access_token_file}" "${access_token}"
      ;;
    *)
      usage
      ;;
  esac
}

linkedin_auth() {
  local client_id
  local client_secret
  local access_token
  local access_token_file
  local access_token_log
  local last_modified
  local current_time

  client_id=$1
  client_secret=$2
  access_token_file=$3
  access_token="$4"

  if [ -z "${access_token}" ]; then
    if [ -z "${client_id}" ]; then
      echo "Client ID not set, use 'LINKEDIN_CLIENT_ID' environment variable."
      exit 1
    fi

    if [ -z "${client_secret}" ]; then
      echo "Client ID not set, use 'LINKEDIN_CLIENT_ID' environment variable."
      exit 1
    fi

    if [ ! -f "${access_token_file}" ]; then
      linkedin_auth_get_access_token "${client_id}" "${client_secret}" "${access_token_file}"
    fi
  fi

  linkedin_auth_check "${access_token_file}" "${access_token}"

  #last_modified=$(linkedin_get_file_timestamp "${access_token_file}")
  #current_time=$(date +%s)
  #expiring_time=$((current_time - last_modified))
  #echo "Expire: $expiring_time"
  #if [ "$expiring_time" -gt "1000" ]; then
  #  linkedin_auth_refresh_access_token "${client_id}" "${client_secret}" "${access_token_file}"
  #fi
}

linkedin_auth_get_access_token() {
  local client_id
  local client_secret
  local access_token_file
  local scope
  local redirect_uri
  local oauth_url
  local message
  local response
  local request
  local code
  local state
  local options

  client_id=$1
  client_secret=$2
  access_token_file=$3
  #state=12345678

  scope="profile%20openid%20w_member_social"
  redirect_uri="http://localhost:9001/"

  oauth_url="https://www.linkedin.com/oauth/v2/authorization"
  oauth_url="${oauth_url}?client_id=$client_id"
  oauth_url="${oauth_url}&redirect_uri=$redirect_uri"
  oauth_url="${oauth_url}&scope=$scope"
  oauth_url="${oauth_url}&response_type=code"
  #oauth_url="${oauth_url}&state=$state"

  echo "Follow the link to authorize the application:"
  echo
  echo "$oauth_url"

  message="<script>fetch(location.href);alert('Authorization complete. You may close this window, then go back to the terminal.');location.reload();</script>"
  response="HTTP/1.1 200 OK\r\nContent-Length: ${#message}\r\n\r\n${message}"

  options="-N"
  [ "$(uname)" = "Darwin" ] && options="-c"
  request=$(echo -ne "${response}" | nc $options -l -p 9001 | sed -n 's/GET \([^ ]*\).*/\1/p')

  code=$(echo "${request}" | sed -n 's/.*\?code=\([^&]*\).*/\1/p')

  oauth_url="https://www.linkedin.com/oauth/v2/accessToken"
  oauth_url="${oauth_url}?client_id=$client_id"
  oauth_url="${oauth_url}&client_secret=$client_secret"
  oauth_url="${oauth_url}&code=$code"
  oauth_url="${oauth_url}&redirect_uri=$redirect_uri"
  oauth_url="${oauth_url}&grant_type=authorization_code"

  response=$(curl -s -H "Content-Type: x-www-form-urlencoded" -d "" -X POST "${oauth_url}")

  echo
  echo "Authorization complete. Access token saved to '${access_token_file}'"

  mkdir -p "$(dirname "${access_token_file}")"

  echo "${response}" > "${access_token_file}"
}

linkedin_auth_refresh_access_token() {
  local client_id
  local client_secret
  local access_token_file
  local refresh_token_url
  local refresh_token

  client_id=$1
  client_secret=$2
  access_token_file=$3

  if [ ! -f "${access_token_file}" ]; then
    echo "Access token file not found: ${access_token_file}"
    exit 1
  fi

  refresh_token=$(sed -n 's/.*"refresh_token": *"\(.*\)".*/\1/p' "${access_token_file}" | cut -d '"' -f 1)

  echo "Refresh token: $refresh_token"

  if [ -z "${refresh_token}" ]; then
    oauth_url="https://www.linkedin.com/oauth/v2/accessToken"
    oauth_url="${oauth_url}?client_id=$client_id"
    oauth_url="${oauth_url}&client_secret=$client_secret"
    oauth_url="${oauth_url}&code=$code"
    oauth_url="${oauth_url}&redirect_uri=$redirect_uri"
    oauth_url="${oauth_url}&grant_type=authorization_code"

    response=$(curl -s -H "Content-Type: x-www-form-urlencoded" -d "" -X POST "${oauth_url}")
  fi

  client_secret_file=$2

  refresh_token_url="https://oauth2.googleapis.com/token"

  client_id=$(sed -n 's/.*"client_id":"\(.*\)".*/\1/p' "${client_secret_file}" | cut -d '"' -f 1)
  client_secret=$(sed -n 's/.*"client_secret":"\(.*\)".*/\1/p' "${client_secret_file}" | cut -d '"' -f 1)
  refresh_token=$(sed -n 's/.*"refresh_token": *"\(.*\)".*/\1/p' "${access_token_file}" | cut -d '"' -f 1)

  access_token=$(curl -s -X POST \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "client_id=$client_id" \
     -d "client_secret=$client_secret" \
     -d "refresh_token=$refresh_token" \
     -d "grant_type=refresh_token" \
     "$refresh_token_url" | sed 's#{#{\n  "refresh_token": "'"${refresh_token}"'",#')

  echo "Access token refreshed: $access_token"

  echo "${access_token}" > "${access_token_file}"
}

linkedin_auth_check() {
  local access_token_file
  local access_token

  access_token_file=$1
  access_token=$2

  if [ -z "${access_token}" ]; then
    if [ ! -f "${access_token_file}" ]; then
      echo "Access token file not found: ${access_token_file}"
      exit 1
    fi
    access_token=$(sed -n 's/.*"access_token": *"\(.*\)".*/\1/p' "${access_token_file}" | cut -d '"' -f 1)
    ## TODO: Check if access token is valid or expired
  fi

  if [ -z "${access_token}" ]; then
    echo "Access token not found, please authenticate first."
    exit 1
  fi
}

linkedin_auth_select_access_token() {
  local access_token_file
  local access_token

  access_token_file=$1
  access_token=$2

  if [ -z "${access_token}" ]; then
    access_token=$(sed -n 's/.*"access_token": *"\(.*\)".*/\1/p' "${access_token_file}" | cut -d '"' -f 1)
  fi

  echo "${access_token}"
}

linkedin_github() {
  local access_token_file
  local access_token

  access_token_file="${1}"
  access_token="${2}"

  linkedin_auth_check "${access_token_file}" "${access_token}"

  access_token=$(linkedin_auth_select_access_token "${access_token_file}" "${access_token}")

  echo "${access_token}" | gh secret set LINEKDIN_ACCESS_TOKEN -R francescobianco/linkedin.sh
}

linkedin_info() {
  local access_token_file
  local access_token
  local userinfo
  local post_file
  local data

  access_token_file=$1
  access_token=$2
  post_file=$3

  access_token=$(linkedin_auth_select_access_token "${access_token_file}" "${access_token}")
  userinfo=$(curl -s -X GET -H "Authorization: Bearer ${access_token}" "https://api.linkedin.com/v2/userinfo")
  name=$(echo "${userinfo}" | sed -n 's/.*"name": *"\(.*\)".*/\1/p' | cut -d '"' -f 1)
  sub=$(echo "${userinfo}" | sed -n 's/.*"sub": *"\(.*\)".*/\1/p' | cut -d '"' -f 1)

  echo "  Name: ${name}"
  echo "   Sub: ${sub}"
  if [ -f "$access_token_file" ]; then
    echo " Token: ${access_token_file}"
  fi
}

linkedin_post() {
  local access_token_file
  local access_token
  local userinfo
  local post_file
  local data

  access_token_file=$1
  access_token=$2
  post_file=$3

  if [ ! -f "${post_file}" ]; then
    echo "Post file not found: $post_file"
    exit 1
  fi

  access_token=$(linkedin_auth_select_access_token "${access_token_file}" "${access_token}")
  userinfo=$(curl -s -X GET -H "Authorization: Bearer ${access_token}" "https://api.linkedin.com/v2/userinfo")
  sub=$(echo "${userinfo}" | sed -n 's/.*"sub": *"\(.*\)".*/\1/p' | cut -d '"' -f 1)

  commentary=$(sed 's/"/\\"/g' "${post_file}")
  commentary=$(echo -n "${commentary}" | awk '{printf "%s\\n", $0}')

  data='{
    "author": "urn:li:person:'"${sub}"'",
    "commentary": "'"${commentary}"'",
    "visibility": "PUBLIC",
    "distribution": {
      "feedDistribution": "MAIN_FEED",
      "targetEntities": [],
      "thirdPartyDistributionChannels": []
    },
    "lifecycleState": "PUBLISHED",
    "isReshareDisabledByAuthor": false
  }'

  curl -s -X POST "https://api.linkedin.com/rest/posts" \
    -H "Authorization: Bearer ${access_token}" \
    -H "X-Restli-Protocol-Version: 2.0.0" \
    -H "LinkedIn-Version: 202401" \
    -H "Content-Type: application/json" \
    --data "${data}"

  echo ""
}

linkedin_get_file_timestamp() {
  local file

  file=$1

  if [ "$(uname)" == "Darwin" ]; then
    stat -f %m "${file}"
  else
    stat -c %Y "${file}"
  fi
}
## BP005: Execute the entrypoint
main "$@"
