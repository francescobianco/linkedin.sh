
linkedin_info() {
  local access_token_file
  local access_token
  local userinfo

  access_token_file=$1

  access_token=$(sed -n 's/.*"access_token": *"\(.*\)".*/\1/p' "${access_token_file}" | cut -d '"' -f 1)

  userinfo=$(curl -s -X GET -H "Authorization: Bearer ${access_token}" "https://api.linkedin.com/v2/userinfo")

  echo "${userinfo}"
}
