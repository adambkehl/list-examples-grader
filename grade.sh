CPATH='.;lib/hamcrest-core-1.3.jar;lib/junit-4.13.2.jar'


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
git clone $1 student-submission # Clones the repo to a folder named student-submission
echo 'Finished cloning' # Print out a little success message


# Test success tracking
passed_tests=0
total_tests=0

# First test, let's simply check that the file we want to grade exists
total_tests=$((total_tests+1))
if [[ -e "student-submission/ListExamples.java" ]]
    then
        passed_tests=$((passed_tests+1))
    else
        echo "Error! No file exists!" 1>&2
        exit 1
fi

# Copy the student submission into the grading area
cp -r student-submission/. grading-area
cp -r lib grading-area
cp TestListExamples.java grading-area
cd grading-area
echo "Copied successfully"


javac -cp $CPATH *.java
echo "Compiled!"

java -cp $CPATH org.junit.runner.JUnitCore TestListExamples
echo "Running!"




# Draw a picture/take notes on the directory structure that's set up after
# getting to this point

# Then, add here code to compile and run, and do any post-processing of the
# tests
