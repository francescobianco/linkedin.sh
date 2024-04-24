
linkedin_get_file_timestamp() {
  local file

  file=$1

  if [ "$(uname)" == "Darwin" ]; then
    stat -f %m "${file}"
  else
    stat -c %Y "${file}"
  fi
}
