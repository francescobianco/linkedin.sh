
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
