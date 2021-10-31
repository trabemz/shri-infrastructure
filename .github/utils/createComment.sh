commentText=$1

OAuth='AQAAAAAQ8JwBAAd4kUjZvmm85E5pm1Pjfx_wZn4'
OrganizationId='6461097'

echo "Getting information from git..."
CurrentGitTag=$(git tag | sort -r | head -1)
echo "Current tag: " $CurrentGitTag
Unique="trabemz_shri-infrastructure_${CurrentGitTag}"
echo "Unique identifier: $Unique"

echo "Getting task url..."
IssueUrl=$(curl --silent --location --request POST 'https://api.tracker.yandex.net/v2/issues/_search' \
--header "Authorization: OAuth $OAuth" \
--header "X-Org-ID: $OrganizationId" \
--header "Content-Type: application/json" \
--data '{
  "filter": {
    "unique": "'"${Unique}"'"
  }
}' | awk -F '"self":"' '{ print $2 }' | awk -F '","' '{ print $1 }'
)
echo "Task Url: $IssueUrl"

echo "Adding comment to task..."

DataRaw='{
        "text": "'"${commentText}"'"
    }'

responseCodeCreateComment=$(curl --silent  -o /dev/null -s -w "%{http_code}" --location --request POST "$IssueUrl/comments" \
--header "Authorization: OAuth $OAuth" \
--header "X-Org-ID: $OrganizationId" \
--header "Content-Type: application/json" \
--data-raw "$DataRaw"
)

if [ "$responseCodeCreateComment" = 201 ]
then echo "Comment created successfully!"
else 
  responseCreateComment=$(curl --silent --location --request POST "$IssueUrl/comments" \
  --header "Authorization: OAuth $OAuth" \
  --header "X-Org-ID: $OrganizationId" \
  --header "Content-Type: application/json" \
  --data-raw "$DataRaw"
  )
  echo "Comment not created."
  echo $responseCreateComment
fi