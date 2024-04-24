
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
