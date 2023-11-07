CPATH='.;lib/hamcrest-core-1.3.jar;lib/junit-4.13.2.jar'

captureoutput() {
  output="$( "$@" )"
  printf '%s\n' "$output"
}

# Test success tracking
passed_tests=0
total_tests=4
testresults() {
    echo "Tests passed: $passed_tests/$total_tests"
}

# Extra from bonus video #1
if [[ $# < 1 ]] # if the number of arguments passed to this bash script is less than 1, then
    then
        echo "Missing arguments!" 1>&2
        exit 1
fi

# Removing previous tests and repos and stuff
rm -rf student-submission
rm -rf grading-area
mkdir grading-area

# 1st step!
# Take an argument to grade.sh and clone it
# e.g. from the command line `bash grade.sh https://github.com/username/myreponame`
# Base sets these for you: $# $1 $2, etc. $# is the number of arguments, $1 is the first arg, etc.
# $1 will be equal to https://github.com/username/myreponame
output=`git clone $1 student-submission --quiet 2>&1` # Clones the repo to a folder named student-submission
if [[ $? -eq 0 ]]
    then
        passed_tests=$((passed_tests+1))
        echo "Test #1 PASSED: Git cloned successfully"
    else
        echo "Test #1 FAILED: Git could not be cloned -- repo may not be entered correctly"
        testresults
        exit 1
fi

# Test #2: let's simply check that the file we want to grade exists
if [[ -e "student-submission/ListExamples.java" ]]
    then
        passed_tests=$((passed_tests+1))
        echo "Test #2 PASSED: ListExamples.java exists in repo"
    else
        echo "Test #2 FAILED: ListExamples.java does not exist in repo"
        testresults
        exit 1
fi

# Copy the student submission into the grading area
cp -r student-submission/. grading-area # copy all files and sub-directories from student-submission to grading-area
cp -r lib grading-area # copy the lib folder to grading-area
cp *.java grading-area # copy all of our test files into the grading-area
cd grading-area # make grading-area our working directory


# Test #3: Check if compilation fails
# Execute javac and redirect stderr to stdout, and capture message in output
output=`javac -cp $CPATH *.java 2>&1`
if [[ $? -eq 0 ]]
    then
        passed_tests=$((passed_tests + 1))
        echo "Test #3 PASSED: Compilation successful"
    else
        echo "Test #3 FAILED: Compilation error:"
        echo "$output"
        testresults
        exit 1
fi



# Checking tests
output=`java -cp $CPATH org.junit.runner.JUnitCore TestListExamples 2>&1`
#echo "$output"
if echo "$output" | grep -q -e "OK\ \(.*\ test.*\)";
    then
        passed_tests=$((passed_tests+1))
        echo "Test #4 PASSED: All JUnit tests passed"
    else
        echo "Test #4 FAILED: Not all JUnit tests passed:"
        echo "$output"
        testresults
        exit 1
fi

testresults