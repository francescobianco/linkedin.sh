
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
  local access_token_env
  local access_token_file
  local access_token_log
  local client_id
  local client_secret

  command=$1
  client_id="${LINKEDIN_CLIENT_ID}"
  client_secret="${LINKEDIN_CLIENT_SECRET}"
  access_token_env="${LINKEDIN_ACCESS_TOKEN}"
  access_token_file="${HOME}/.linkedin/access_token.json"
  access_token_log="$${LINKEDIN_ACCESS_TOKEN_LOG}"

  case $command in
    --help|-h)
      usage
      ;;
    post)
      linkedin_auth "${client_id}" "${client_secret}" "${access_token_file}" "${access_token_env}" "${access_token_log}"
      ;;
    info)
      linkedin_auth "${client_id}" "${client_secret}" "${access_token_file}" "${access_token_env}" "${access_token_log}"
      ;;
    refresh-access-token)
      linkedin_auth "${client_id}" "${client_secret}" "${access_token_file}" "${access_token_env}" "${access_token_log}"
      ;;
    *)
      usage
      ;;
  esac
}
