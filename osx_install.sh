#!/bin/bash

echo --- installing dependencies..

echo --- installing hugo..
brew install hugo

echo --- installing gomplate..
brew install hairyhenderson/tap/gomplate

echo --- installing hub
brew install hub

echo --- installing up..
curl -sf https://up.apex.sh/install | sh

hugo version
gomplate -v
hub --version
up version

echo --- all done
