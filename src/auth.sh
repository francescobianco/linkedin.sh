
linkedin_auth() {
  local access_token_file
  local client_secret_file
  local last_modified
  local current_time

  access_token_file=$1
  client_secret_file=$2

  if [ ! -f "${access_token_file}" ]; then
    linkedin_auth_get_access_token "${access_token_file}" "${client_secret_file}"
  fi

  last_modified=$(google_calendar_script_file_timestamp "${access_token_file}")
  current_time=$(date +%s)
  expiring_time=$((current_time - last_modified))

  echo "$expiring_time"

  if [ "$expiring_time" -gt "1000" ]; then
    google_calendar_script_refresh_access_token "${access_token_file}" "${client_secret_file}"
  fi
}

linkedin_auth_get_access_token() {
  local access_token_file
  local client_secret_file
  local client_id
  local client_secret
  local scope
  local redirect_uri
  local oauth_url
  local message
  local response
  local request
  local code

  access_token_file=$1
  client_secret_file=$2

  client_id=$(sed -n 's/.*"client_id":"\(.*\)".*/\1/p' "${client_secret_file}" | cut -d '"' -f 1)
  client_secret=$(sed -n 's/.*"client_secret":"\(.*\)".*/\1/p' "${client_secret_file}" | cut -d '"' -f 1)

  scope="https://www.googleapis.com/auth/calendar.readonly"
  redirect_uri="http://localhost:9000"

  oauth_url="https://accounts.google.com/o/oauth2/auth"
  oauth_url="${oauth_url}?client_id=$client_id"
  oauth_url="${oauth_url}&redirect_uri=$redirect_uri"
  oauth_url="${oauth_url}&scope=$scope"
  oauth_url="${oauth_url}&response_type=code"
  oauth_url="${oauth_url}&access_type=offline"

  echo "Follow the link to authorize the application:"
  echo
  echo "$oauth_url"

  message="Authorization complete. You may close this window, then go back to the terminal."
  response="HTTP/1.1 200 OK\r\nContent-Length: ${#message}\r\n\r\n${message}"
  request=$(echo -ne "${response}" | nc -l -p 9000 | sed -n 's/GET \([^ ]*\).*/\1/p')

  code=$(echo "${request}" | sed -n 's/.*\?code=\([^&]*\).*/\1/p')

  request="client_id=$client_id&client_secret=$client_secret&code=$code&redirect_uri=$redirect_uri&grant_type=authorization_code"
  response=$(curl -s -d "${request}" "https://oauth2.googleapis.com/token")

  echo
  echo "Authorization complete. Access token saved to '${access_token_file}'"
  echo "${response}" > "${access_token_file}"
}

google_calendar_script_refresh_access_token() {
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