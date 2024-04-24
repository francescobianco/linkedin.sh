
linkedin_post() {
  local access_token_file
  local access_token
  local userinfo

  access_token_file=$1

  access_token=$(sed -n 's/.*"access_token": *"\(.*\)".*/\1/p' "${access_token_file}" | cut -d '"' -f 1)

  userinfo=$(curl -s -X GET -H "Authorization: Bearer ${access_token}" "https://api.linkedin.com/v2/userinfo")

  sub=$(echo "${userinfo}" | sed -n 's/.*"sub": *"\(.*\)".*/\1/p' | cut -d '"' -f 1)

  echo "User ID: ${sub}"
  exit

  curl -s -X POST 'https://api.linkedin.com/rest/posts' \
  -H "Authorization: Bearer ${access_token}" \
  -H 'X-Restli-Protocol-Version: 2.0.0' \
  -H "LinkedIn-Version: 202401" \
  -H "Content-Type: application/json" \
  --data '{
    "author": "urn:li:person:'"${sub}"'",
    "commentary": "Sample text Post",
    "visibility": "PUBLIC",
    "distribution": {
      "feedDistribution": "MAIN_FEED",
      "targetEntities": [],
      "thirdPartyDistributionChannels": []
    },
    "lifecycleState": "PUBLISHED",
    "isReshareDisabledByAuthor": false
  }'

  echo ""
}
