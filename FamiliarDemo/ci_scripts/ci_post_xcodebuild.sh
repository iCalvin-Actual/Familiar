#!/bin/zsh
# Xcode Cloud runs this after every xcodebuild action.
# A signed build is headed for TestFlight: say what changed.
if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
    git fetch --tags --deepen 50
    since=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null)
    mkdir -p ../TestFlight
    git log -n 10 --pretty=format:"• %s" ${since:+$since..}HEAD \
        > ../TestFlight/WhatToTest.en-US.txt
fi
