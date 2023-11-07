CPATH='.;lib/hamcrest-core-1.3.jar;lib/junit-4.13.2.jar'

# Test success tracking
passed_tests=0
total_tests=4

# Function to call each time we want to print out the number of tests that have passed
testresults() {
    printf "\nTests passed: $passed_tests/$total_tests"
}

# (Extra from bonus video #1)
# If we don't provide the correct number of arguments to this bash script, it will error
if [[ $# -ne 1 ]]; then
    echo "Wrong number of arguments! Want just a github repo link" 1>&2
    exit 1
fi

# Remove previous temporary directories, files, repos
rm -rf student-submission
rm -rf grading-area
mkdir grading-area # make new grading-area directory


# We'll call this script from the command line like
# `bash grade.sh https://github.com/username/myreponame`

# Bash sets these automatically: $# $1 $2, etc.
# $# is the number of arguments, $1 is the first argument, $2 is the second argument, etc.
# $1 will be equal to https://github.com/username/myreponame

# This step clones the repo to a folder named student-submission.
# If there's any standard error output (stderr), convert it to standard
# output (stdout) and save it to the output variable.
git clone $1 student-submission --quiet
if [[ $? -eq 0 ]]; then # if the exit code of the last command was 0 (success)
    passed_tests=$((passed_tests + 1))
    echo "Test #1 PASSED: Repo cloned successfully"
else
    echo "Test #1 FAILED: Repo could not be cloned"
    testresults
    exit 1
fi

# Test #2: let's simply check that the file we want to grade exists
if [[ -e "student-submission/ListExamples.java" ]]; then
    passed_tests=$((passed_tests+1))
    echo "Test #2 PASSED: ListExamples.java exists"
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
if [[ $? -eq 0 ]]; then # the javac command was the last command executed, this checks if it was successful
    passed_tests=$((passed_tests + 1))
    echo "Test #3 PASSED: Compilation successful"
else
    printf "Test #3 FAILED: Compilation error:\n$output"
    testresults
    exit 1
fi


# Run JUnit tests and check if there's a specific string that looks like "OK (# tests)" where # is
# any number. This uses a simple regular expression with grep (regex)
# We echo the output into grep using the pipe symbol, then we use the -q flag with grep to only return
# whether it was successful or not
output=`java -cp $CPATH org.junit.runner.JUnitCore TestListExamples 2>&1`
if echo "$output" | grep -q -e "OK\ \(.*\ test.*\)"; then
    passed_tests=$((passed_tests+1))
    echo "Test #4 PASSED: All JUnit tests passed"
else
    printf "Test #4 FAILED: Not all JUnit tests passed:\n$output"
    testresults
    exit 1
fi

testresults