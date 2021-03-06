#! /usr/bin/bash
echo "Running tests..."
testSuites=$(npx jest --noStackTrace 2>&1)
echo $testSuites
if [[ $testSuites == *"FAIL"* ]]
then
  result="!!Test suites were failed! Check your repository.!!"
else 
  result="All test were passed successfully."
fi

echo $result

chmod +x ./.github/utils/createComment.sh
./.github/utils/createComment.sh "$result"