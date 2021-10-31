#!/bin/bash
#to delete
OAuth='AQAAAAAQ8JwBAAd4kUjZvmm85E5pm1Pjfx_wZn4'
OrganizationId='6461097'


#git info
echo "Getting information from git..."
CurrentGitTag=$(git tag | sort -r | head -1)
PreviousGitTag=$(git tag | sort -r | head -2 | tail -1)

echo "Current tag: " $CurrentGitTag
echo "Previous tag: " $PreviousGitTag

Release=`git show $CurrentGitTag --pretty=format:"%as" --no-patch | tr -s "\n" " "`
GitLog=`git log ${PreviousGitTag}..${CurrentGitTag} --pretty=format:"\n* %h (%cs) %s - %cn %ce;" | tr -s "\n" " "`


Summary="Release ${CurrentGitTag}"
echo "Title: $Summary"
Description="Release: ${Release}\nChangelog:\n${GitLog}" 
echo "Description: $Description"
Unique="trabemz_shri-infrastructure_${CurrentGitTag}"
echo "Unique identifier: $Unique"

#create task in tracker
echo "Creating task in tracker..."
DataRaw='{
        "queue": "TMP",
        "summary": "'"${Summary}"'",
        "description": "'"${Description}"'",
        "unique": "'"${Unique}"'"
    }'

responseCodeCreate=$(curl -o /dev/null -s -w "%{http_code}" --location --request POST 'https://api.tracker.yandex.net/v2/issues/' \
--header "Authorization: OAuth $OAuth" \
--header "X-Org-ID: $OrganizationId" \
--header "Content-Type: application/json" \
--data-raw "$DataRaw"
)
if [ "$responseCodeCreate" = 409 ]
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
  echo "Task Url: $IssueUrl"

  #Update task
  responseCodeUpdate=$(curl -o /dev/null -s -w "%{http_code}" --location --request PATCH "$IssueUrl" \
  --header "Authorization: OAuth $OAuth" \
  --header "X-Org-ID: $OrganizationId" \
  --header "Content-Type: application/json" \
  --data-raw "$DataRaw"
  )
  if [ "$responseCodeUpdate" = 200 ]
  then echo "Task updated successfully!" 
  else 
    echo "Update return code $responseCodeUpdate"
    responseUpdate=$(curl --location --request PATCH "$IssueUrl" \
    --header "Authorization: OAuth $OAuth" \
    --header "X-Org-ID: $OrganizationId" \
    --header "Content-Type: application/json" \
    --data-raw "$DataRaw"
    )
    echo responseUpdate
  fi
else 
  if [ "$responseCodeCreate" = 201 ]
  then echo "Task created successfully!" 
  else 
    echo "Create return code $responseCodeCreate"
    responseCreate=$(curl --location --request POST 'https://api.tracker.yandex.net/v2/issues/' \
    --header "Authorization: OAuth $OAuth" \
    --header "X-Org-ID: $OrganizationId" \
    --header "Content-Type: application/json" \
    --data-raw "$DataRaw"
    )
    echo $responseCreate
  fi
fi