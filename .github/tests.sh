#! /usr/bin/bash

testSuites=$(npx jest 2>&1)

if [ $testSuites == *"FAIL"* ]
then
  echo "Test Suites were failed"
fi

echo $testSuites
