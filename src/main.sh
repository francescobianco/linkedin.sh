
module auth
module github
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
