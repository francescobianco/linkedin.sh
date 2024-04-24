
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
  local client_secret_file
  local event_state

  command=$1
  access_token_file="${HOME}/.linkedin/access_token.json"
  client_secret_file="${HOME}/.linkedin/client_secret.json"

  case $command in
    --help|-h)
      usage
      ;;
    post)
      google_calendar_script_auth "${access_token_file}" "${client_secret_file}"
      google_calendar_script_events "${db_file}" "${script_file}" "${access_token_file}" 1800
      ;;
    *)
      usage
      ;;
  esac
}
