
linkedin_group_members() {
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
  echo "$userinfo"
  sub=$(echo "${userinfo}" | sed -n 's/.*"sub": *"\(.*\)".*/\1/p' | cut -d '"' -f 1)

  #8850995


 # curl -s -X GET -H "Authorization: Bearer ${access_token}" "https://api.linkedin.com/v2/groupDefinitions/8850995"
 # curl -s -X GET \
 #   -H "Authorization: Bearer ${access_token}" \
 #    -H 'X-Restli-Protocol-Version: 2.0.0' \
 #   "https://api.linkedin.com/v2/groupMemberships?q=member&member=${sub}"

  #exit

  commentary="test"
  exit
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

  curl -s -X POST "https://api.linkedin.com/v2/posts" \
    -H "Authorization: Bearer ${access_token}" \
    -H "X-Restli-Protocol-Version: 2.0.0" \
    -H "LinkedIn-Version: 202401" \
    -H "Content-Type: application/json" \
    --data "${data}"

  echo ""
}
