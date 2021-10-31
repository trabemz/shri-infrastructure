#! /usr/bin/bash
echo "Running tests..."
testSuites=$(npx jest --noStackTrace 2>&1)

if [[ $testSuites == *"FAIL"* ]]
then
  result="!!Test suites were failed! Check your repository.!!"
else 
  result="All test were passed successfully."
fi

echo $result

./.github/utils/createComment.sh "$result"