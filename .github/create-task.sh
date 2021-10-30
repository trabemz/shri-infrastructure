#!/bin/bash
PreviousAndCurrentGitTag=`git describe --tags \`git rev-list --tags --abbrev=0 --max-count=2\` --abbrev=0`
PreviousGitTag=`echo $PreviousAndCurrentGitTag | cut -f 2 -d ' '`
CurrentGitTag=`echo $PreviousAndCurrentGitTag | cut -f 1 -d ' '`

echo "Current tag: " $CurrentGitTag
echo "Previous tag: " $PreviousGitTag

ReleaseDate=`git rev-parse ${CurrentGitTag} | xargs git cat-file -p | awk '/^tagger/ { print "@" $(NF-1) }' | xargs -i date -d "{}" "+%Y-%m-%d" `
echo "Release date: " $ReleaseDate
ReleaseCreator=`git rev-parse ${CurrentGitTag} | xargs git cat-file -p | awk '/^tagger/ { print $2 " " $3 " " $4 }'`
echo "Release author: " $ReleaseCreator
GitLog=`git log ${PreviousGitTag}..${CurrentGitTag} --pretty=tformat:"%h; author: %cn; date: %cs; subject:%s ||" | awk '||'`
echo $GitLog 