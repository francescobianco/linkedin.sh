
linkedin_github() {
  local access_token_file
  local access_token

  access_token_file="${1}"
  access_token="${2}"

  linkedin_auth_check "${access_token_file}" "${access_token}"

  access_token=$(linkedin_auth_select_access_token "${access_token_file}" "${access_token}")

  echo "${access_token}" | gh secret set LINEKDIN_ACCESS_TOKEN -R francescobianco/linkedin.sh
}
