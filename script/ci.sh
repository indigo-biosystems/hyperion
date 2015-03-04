#!/bin/bash
TEST_STATUS=0
COLOR_FLAG="-c"
OUTPUT_DIR="target"

processOptions(){
    while getopts ":o:bh" option; do
        case "${option}" in
            o  ) OUTPUT_DIR="${OPTARG}" ;;
            b  ) COLOR_FLAG="--no-colour" ;;
            h  ) usageWithExit 0 ;;
            \? ) usageWithExit 1 ;;
        esac
    done
    [ $((${OPTIND}-1)) -ne $# ] && usageWithExit 1
}

usageWithExit(){
    local rc="$1"
    usage
    exit ${rc}
}

usage(){
    echo "
Usage: ci.sh [-o OUTPUT_DIR] [-b] [-h]
  -h   Help message
  -o   Directory for reports (default 'target')
  -b   Black and white, no color encodings (default is color)"
}

initReportDirectory(){
    REPORT_PATH="${OUTPUT_DIR}/reports"
    mkdir -p "${REPORT_PATH}"
}

runTests(){
    runRspecTests
}

runRspecTests(){
    echo -e '\nRunning RSpec'
    local html_report="-fh -o ${REPORT_PATH}/traceability-unit.html"
    local junit_report="-fRspecJunitFormatter -o ${REPORT_PATH}/rspec.xml"
    local text_report="-fp -o ${REPORT_PATH}/rspec.txt"
    local stdout_report="-fp"
   CODECLIMATE_REPO_TOKEN=1aea6fbe49da6151ff57209adcbdbf4746058d1d043f98ca8b7e7f1ea18e8cab bundle exec rspec ${COLOR_FLAG} ${html_report} ${junit_report} ${text_report} ${stdout_report} || ((TEST_STATUS += 4))
}

writeTestSummary(){
    echo -e "\n\n=== Test Results ===\n"
    echo -e "Rspec\n$(sed -n '/^Finished in /,/^$/ p' "${REPORT_PATH}/rspec.txt")\n"
}

exitScript(){
    echo -e "Test status: ${TEST_STATUS}"
    exit ${TEST_STATUS}
}

processOptions "$@"
initReportDirectory
runTests
writeTestSummary
exitScript
