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
curl -o "template.zip" "$url" || die "Failed to download the template from $url"

unzip "template.zip" || die "Failed to unzip the template"
dir_created=$(unzip -l template.zip | head -n 4 | tail -n 1 | awk '{print $4}')
cd "$dir_created" || die "Failed to change directory to $dir_created"
zip -r "files.zip" ./* || die "Failed to create files.zip from the template directory"

mv files.zip ../ || die "Failed to move files.zip to parent directory"
cd ../../ || die "Failed to change directory to main directory"

# remove created files
rm -rf files/template.zip "files/$dir_created" || die "Failed to remove temporary files"
