#!/bin/bash
# shellcheck disable=SC1091
source "./functions.sh"

url="$1"
if [[ -z "$url" ]]; then
    print_error "You must provide a URL to download the template url"
    exit 1
fi

# download tooplate template
cd files || die "Failed to change directory to files"
curl -o "files.zip" "$url" || die "Failed to download the template from $url"