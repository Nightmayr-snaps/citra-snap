#!/bin/bash
# set -x

# check latest tagged version
LATEST_NIGHTLY_VERSION_TAG="$(curl https://api.github.com/repos/citra-emu/citra-nightly/releases/latest -s | jq .tag_name -r)"
LATEST_CANARY_VERSION_TAG="$(curl https://api.github.com/repos/citra-emu/citra-canary/releases/latest -s | jq .tag_name -r)"
CURRENT_NIGHTLY_VERSION_TAG="$(yq e '.parts.citra-nightly.source-tag' snap/snapcraft.yaml)"
CURRENT_CANARY_VERSION_TAG="$(yq e '.parts.citra-canary.source-tag' snap/snapcraft.yaml)"
CURRENT_NIGHTLY_VERSION_SNAP=${CURRENT_NIGHTLY_VERSION_TAG#nightly-}
CURRENT_CANARY_VERSION_SNAP=${CURRENT_CANARY_VERSION_TAG#canary-}
LATEST_CANARY_VERSION=${LATEST_CANARY_VERSION_TAG#canary-}
LATEST_NIGHTLY_VERSION=${LATEST_NIGHTLY_VERSION_TAG#nightly-}

# compare versions
if [ $CURRENT_NIGHTLY_VERSION_TAG != $LATEST_NIGHTLY_VERSION_TAG ] || [ $CURRENT_CANARY_VERSION_TAG != $LATEST_CANARY_VERSION_TAG ]; then
    if [ $CURRENT_NIGHTLY_VERSION_TAG != $LATEST_NIGHTLY_VERSION_TAG ] && [ $CURRENT_CANARY_VERSION_TAG != $LATEST_CANARY_VERSION_TAG ]; then
        echo "versions don't match"
        echo "citra-nightly:: github: $LATEST_NIGHTLY_VERSION_TAG snap: $CURRENT_NIGHTLY_VERSION_TAG"
        echo "citra-canary:: github: $LATEST_CANARY_VERSION_TAG snap: $CURRENT_CANARY_VERSION_TAG"
        echo "updating snapcraft.yaml with new versions"
        yq eval ".parts.citra-nightly.source-tag = \"$LATEST_NIGHTLY_VERSION_TAG\"" -i snap/snapcraft.yaml
        yq eval ".parts.citra-nightly.build-environment[2].TRAVIS_TAG = \"$LATEST_NIGHTLY_VERSION_TAG\"" -i snap/snapcraft.yaml
        yq eval ".parts.citra-canary.source-tag = \"$LATEST_CANARY_VERSION_TAG\"" -i snap/snapcraft.yaml
        yq eval ".parts.citra-canary.build-environment[2].TRAVIS_TAG = \"$LATEST_CANARY_VERSION_TAG\"" -i snap/snapcraft.yaml
        yq eval ".version = \"C$LATEST_CANARY_VERSION-N$LATEST_NIGHTLY_VERSION\"" -i snap/snapcraft.yaml
    elif [ $CURRENT_NIGHTLY_VERSION_TAG != $LATEST_NIGHTLY_VERSION_TAG ]; then
        echo "citra-nightly versions don't match, github: $LATEST_NIGHTLY_VERSION_TAG snap: $CURRENT_NIGHTLY_VERSION_TAG"
        echo "updating snapcraft.yaml with new nightly version"
        yq eval ".parts.citra-nightly.source-tag = \"$LATEST_NIGHTLY_VERSION_TAG\"" -i snap/snapcraft.yaml
        yq eval ".parts.citra-nightly.build-environment[2].TRAVIS_TAG = \"$LATEST_NIGHTLY_VERSION_TAG\"" -i snap/snapcraft.yaml
        yq eval ".version = \"C$CURRENT_CANARY_VERSION_SNAP-N$LATEST_NIGHTLY_VERSION\"" -i snap/snapcraft.yaml
    else
        echo "citra-canary versions don't match, github: $LATEST_CANARY_VERSION_TAG snap: $CURRENT_CANARY_VERSION_TAG"
        echo "updating snapcraft.yaml with new canary version"
        yq eval ".parts.citra-canary.source-tag = \"$LATEST_CANARY_VERSION_TAG\"" -i snap/snapcraft.yaml
        yq eval ".parts.citra-canary.build-environment[2].TRAVIS_TAG = \"$LATEST_CANARY_VERSION_TAG\"" -i snap/snapcraft.yaml
        yq eval ".version = \"C$LATEST_CANARY_VERSION-N$CURRENT_NIGHTLY_VERSION_SNAP\"" -i snap/snapcraft.yaml
    fi
    echo true > build
else
    echo "versions match"
    echo "citra-nightly:: github: $LATEST_NIGHTLY_VERSION_TAG snap: $CURRENT_NIGHTLY_VERSION_TAG"
    echo "citra-canary:: github: $LATEST_CANARY_VERSION_TAG snap: $CURRENT_CANARY_VERSION_TAG"
    echo false > build
fi


