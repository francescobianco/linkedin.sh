#!/usr/bin/env bash
# @BP010: Release metadata
# @package: linkedin.sh
# @build_type: bin
# @build_with: Mush 0.2.0 (2024-03-21)
# @build_date: 2024-04-28T08:59:37Z
set -e
use() { return 0; }
extern() { return 0; }
legacy() { return 0; }
module() { return 0; }
public() { return 0; }
embed() { return 0; }
## BP004: Compile the entrypoint

module auth
module util

usage() {
  echo "Usage: linkedin.sh [COMMAND] [OPTIONS]"
  echo ""
  echo "Available commands"
  echo "  post POSTFILE          Post content of POSTFILE to LinkedIn"
}

main() {
  local command
  local access_token_file
  local client_id
  local client_secret
  local event_state

  command=$1
  access_token_file="${HOME}/.linkedin/access_token.json"

  case $command in
    --help|-h)
      usage
      ;;
    post)
      linkedin_auth "${access_token_file}" "${client_id}" "${client_secret}"
      #google_calendar_script_events "${db_file}" "${script_file}" "${access_token_file}" 1800
      ;;
    info)
      linkedin_auth "${access_token_file}" "${client_id}" "${client_secret}"
      google_calendar_script_events "${db_file}" "${script_file}" "${access_token_file}" 1800
      ;;
    *)
      usage
      ;;
  esac
}

linkedin_auth() {
  local access_token_file
  local client_secret_file
  local last_modified
  local current_time

  access_token_file=$1
  client_id=$2
  client_secret=$3

  if [ ! -f "${access_token_file}" ]; then
    linkedin_auth_get_access_token "${access_token_file}" "${client_id}" "${client_secret}"
  fi

  last_modified=$(linkedin_get_file_timestamp "${access_token_file}")
  current_time=$(date +%s)
  expiring_time=$((current_time - last_modified))

  #echo "Expire: $expiring_time"

  #if [ "$expiring_time" -gt "1000" ]; then
  #  linkedin_auth_refresh_access_token "${access_token_file}" "${client_secret_file}"
  #fi
}

linkedin_auth_get_access_token() {
  local access_token_file
  local client_id
  local client_secret
  local scope
  local redirect_uri
  local oauth_url
  local message
  local response
  local request
  local code
  local state

  access_token_file=$1
  client_id=$2
  client_secret=$3
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

  message="<script>alert('Authorization complete. You may close this window, then go back to the terminal.');location.reload();</script>"
  response="HTTP/1.1 200 OK\r\nContent-Length: ${#message}\r\n\r\n${message}"

  request=$(echo -ne "${response}" | nc -N -l -p 9001 | sed -n 's/GET \([^ ]*\).*/\1/p')

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
  echo "${response}" > "${access_token_file}"
}

linkedin_auth_refresh_access_token() {
  local access_token_file
  local client_secret_file
  local client_id
  local client_secret
  local refresh_token_url
  local refresh_token

  access_token_file=$1
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
