
linkedin_post() {
  local access_token_file
  local access_token
  local userinfo
  local post_file
  local data

  access_token_file=$1
  access_token=$2

  if [ -z "${access_token}" ]; then
    if [ ! -f "${access_token_file}" ]; then
      echo "Access token file not found: ${access_token_file}"
      exit 1
    fi
    access_token=$(sed -n 's/.*"access_token": *"\(.*\)".*/\1/p' "${access_token_file}" | cut -d '"' -f 1)
  fi

  if [ -z "${access_token}" ]; then
    echo "Access token not found, please authenticate first."
    exit 1
  fi

  userinfo=$(curl -s -X GET -H "Authorization: Bearer ${access_token}" "https://api.linkedin.com/v2/userinfo")
  sub=$(echo "${userinfo}" | sed -n 's/.*"sub": *"\(.*\)".*/\1/p' | cut -d '"' -f 1)

  post_file=$2

  commentary=$(sed 's/"/\\"/g' "${post_file}")
  commentary=$(echo -n "${commentary}" | sed ':a;N;$!ba;s/\n/\\n/g')

  data='{
    "author": "urn:li:person:'"${sub}"'",
    "commentary": "'"${commentary}"'",
    "visibility": "PUBLIC",
    "distribution": {
      "feedDistribution": "MAIN_FEED",
      "targetEntities": [],
      "thirdPartyDistributionChannels": []
    },
    "lifecycleState": "PUBLISHED",
    "isReshareDisabledByAuthor": false
  }'

  #echo "${data}"

  #exit
  curl -s -X POST "https://api.linkedin.com/rest/posts" \
    -H "Authorization: Bearer ${access_token}" \
    -H "X-Restli-Protocol-Version: 2.0.0" \
    -H "LinkedIn-Version: 202401" \
    -H "Content-Type: application/json" \
    --data "${data}"

  echo ""
}
