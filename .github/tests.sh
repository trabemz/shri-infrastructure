#! /usr/bin/bash
echo "Running tests..."
testSuites=$(npx jest 2>&1)

if [ $testSuites == *"FAIL"* ]
then
  echo "Test suites were failed!"
fi

echo "Result: $testSuites"


echo "Getting information from git..."
CurrentGitTag=$(git tag | sort -r | head -1)
echo "Current tag: " $CurrentGitTag


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
        "text": "'"${testSutes}"'"
    }'

responseCodeCreateComment=$(curl --silent  -o /dev/null -s -w "%{http_code}" --location --request POST "$IssueUrl/comments" \
--header "Authorization: OAuth $OAuth" \
--header "X-Org-ID: $OrganizationId" \
--header "Content-Type: application/json" \
--data-raw "$DataRaw"
)
if [$responseCodeCreateComment = 201]
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

