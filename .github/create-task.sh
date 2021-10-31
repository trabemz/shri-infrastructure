#!/bin/bash

#git info
echo "Getting information from git..."
PreviousAndCurrentGitTag=`git describe --tags \`git rev-list --tags --abbrev=0 --max-count=2\` --abbrev=0`
PreviousGitTag=`echo $PreviousAndCurrentGitTag | cut -f 2 -d ' '`
CurrentGitTag=`echo $PreviousAndCurrentGitTag | cut -f 1 -d ' '`

echo "Current tag: " $CurrentGitTag
echo "Previous tag: " $PreviousGitTag

Release=`git show $CurrentGitTag --pretty=format:"%as" --no-patch | tr -s "\n" " "`
GitLog=`git log ${PreviousGitTag}..${CurrentGitTag} --pretty=format:"\n* %h (%cs) %s - %cn %ce;" | tr -s "\n" " "`
echo $GitLog
echo $Release
#create task in tracker
echo "Creating task in tracker..."
Summary="Release ${CurrentGitTag}"
echo $Summary
Description="Release: ${Release}\nChangelog:\n${GitLog}" 
echo $Description
Unique="trabemz_shri-infrastructure_${CurrentGitTag}"
echo $Unique

DataRaw='{
        "queue": "TMP",
        "summary": "'"${Summary}"'",
        "description": "'"${Description}"'",
        "unique": "'"${Unique}"'"
    }'

responseCode=$(curl -o /dev/null -s -w "%{http_code}" --location --request POST 'https://api.tracker.yandex.net/v2/issues/' \
--header "Authorization: OAuth $OAuth" \
--header "X-Org-ID: $OrganizationId" \
--header "Content-Type: application/json" \
--data-raw "$DataRaw"
)
echo $responseCode

if [ "$responseCode" = 409 ]
then 
  echo 'The task was created in the tracker earlier.'
  echo 'Updating task in tracker...'

  #Get task update link
  IssueUrl=$(curl --location --request POST 'https://api.tracker.yandex.net/v2/issues/_search' \
  --header "Authorization: OAuth $OAuth" \
  --header "X-Org-ID: $OrganizationId" \
  --header "Content-Type: application/json" \
  --data '{
    "filter": {
      "unique": "'"${Unique}"'"
    }
  }' | awk -F '"self":"' '{ print $2 }' | awk -F '","' '{ print $1 }'
  )
  echo $IssueUrl

  #Update task
  responseCodeUpdate=$(curl -o /dev/null -s -w "%{http_code}" --location --request PATCH "$IssueUrl" \
  --header "Authorization: OAuth $OAuth" \
  --header "X-Org-ID: $OrganizationId" \
  --header "Content-Type: application/json" \
  --data-raw "$DataRaw"
  )

  echo $responseCodeUpdate
  if [ "$responseCodeUpdate" = 200 ]
  then echo "Task updated successfully!" 
  else echo "Update return code $responseCodeUpdate"
  fi
else echo "Task created successfully!" 
fi