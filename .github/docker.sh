#! /usr/bin/bash
CurrentGitTag=$(git tag | sort -r | head -1)
image="shri-infrastructure-$CurrentGitTag"

docker build . -f Dockerfile -t ${image}

if [ $? -ne 0 ]
then
    result="!!ERROR with create docker image!!"
    exit 1
else
    result="Created docker image: ${image}"
fi

echo $result

chmod +x ./.github/utils/createComment.sh
./.github/utils/createComment.sh "$result"