#!/bin/bash

if [ -z "$1" ]; then
    echo $0: usage: fetch_theme.sh VERSION "(e.g. fetch_theme.sh 0.0.1)"
    exit 1
fi

VERSION=$1

mkdir -p website/themes/fylo
curl -sL https://github.com/public-tech/fylo-website-hugo-theme/archive/v.$VERSION.tar.gz | tar xz --directory website/themes/fylo --strip 1
echo --- installed theme version "'$VERSION'" to: website/themes/fylo
