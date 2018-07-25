#!/bin/bash

if [ -z "$1" ]; then
    echo $0: usage: test.sh TEST_TYPE "(UNIT|SMOKE)"
    exit 1
fi

TEST_TYPE=$1

# params root_dir
function checkGeneratedWebsite {
    cd "$1"
    #check the contents of the /website dir were created OK
    if [ -f "./up.json" ]; then
        echo "up.json present - checking generated website"
        if [ -d "./website" ]; then
            echo "website dir exists - checking contents"
            if [ -d "./website/output" ]; then
                echo "contents OK"
                if [ -f "./website/themes/fylo/README.md" ]; then
                    echo "theme exists"
                else
                    exit 1
                fi
            else
                exit 1
            fi
        else
            exit 1
        fi
    else
        exit 1
    fi    
}

# params url, content
function checkWebsiteContent {
    echo "testing url: $1 is available.."
    res=$(curl -s $1)
    if [[ ! -z $res ]]; then
        echo "site is available - checking it contains the string: '$2' .."
        # check if the keyword is in the returned content
        if echo "$res" | grep "$2"; then
          echo "content returned OK"
        else
          exit 1
        fi    
    else
        echo "error"
        exit 1
    fi
}

# params UNIT|SMOKE
if [ $TEST_TYPE == "UNIT" ]; then
    checkGeneratedWebsite "$2"
elif [ $TEST_TYPE == "SMOKE" ]; then
    checkWebsiteContent "$2" "$3"
else
    echo "error: params need to be UNIT or SMOKE"
    exit 1
fi
