
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
