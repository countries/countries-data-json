#!/bin/bash

set -e

function checksum-cache {
  cat .github/.auto-update-checksum-cache || echo null
}

function compute_data_checksum {
  find data -name "*.yaml" -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum | awk -F' ' '{print $1}'
}

function unknown_error {
    echo "An inconsistency in the fetched data was detected. Aborting"
    exit 1
}

function print_checksums {
    echo "Local  version SHA:" $LOCAL_COPY_SHA
    echo "Remote version SHA:" $REMOTE_COPY_SHA
}

function fetch_cached_checksum {
    LOCAL_COPY_SHA=$(checksum-cache)
}

function cache_local_checksum {
    echo $LOCAL_COPY_SHA > .github/.auto-update-checksum-cache
}

function compute_local_checksumm {
    LOCAL_COPY_SHA=$(compute_data_checksum)
}

function compute_remote_checksum {
    cd hexorx_countries/lib/countries/
    REMOTE_COPY_SHA=$(compute_data_checksum)
    cd "../../../"
}

function exit_if_no_changes {
  if [ "$LOCAL_COPY_SHA" == "$REMOTE_COPY_SHA" ]; then
    echo "No changes detected"
    cleanup_remote_repository
    exit 0
  fi
}

function fetch_remote_repository {
    git clone --depth 1 https://github.com/hexorx/countries.git --single-branch hexorx_countries
}

function copy_data {
    mkdir -p ./data
    cp -r hexorx_countries/lib/countries/data/* ./data
    cp hexorx_countries/LICENSE data/
}

function cleanup_remote_repository {
    rm -rf hexorx_countries
}

function validate_yaml_data {
    if [ ! -f "data/countries/AD.yaml" ]; then unknown_error; fi
    if [ ! -f "data/countries/ZW.yaml" ]; then unknown_error; fi
    if [ ! -f "data/subdivisions/AD.yaml" ]; then unknown_error; fi
    if [ ! -f "data/subdivisions/ZW.yaml" ]; then unknown_error; fi
    find data -name "*.yaml" -type f -print0 | xargs -0 -P 8 yq type > /dev/null || unknown_error
}

function validate_json_data {
    if [ ! -f "data/countries/AD.json" ]; then unknown_error; fi
    if [ ! -f "data/countries/ZW.json" ]; then unknown_error; fi
    if [ ! -f "data/subdivisions/AD.json" ]; then unknown_error; fi
    if [ ! -f "data/subdivisions/ZW.json" ]; then unknown_error; fi
    find data -name "*.json" -type f -print0 | xargs -0 -P 8 jq type > /dev/null || unknown_error
}

function convert_yaml_to_json {
    find data -name "*.yaml" -type f -print0 | xargs -0 -P 8 -I {} sh -c 'cat $0 | $HOME/.local/bin/yq . > ${0%.*}.json && echo >> ${0%.*}.json && rm $0' {}
}

function commit_changes {
    git add data
    git add .github/.auto-update-checksum-cache
    git config --local user.email "itay+89bf5c@grudev.com"
    git config --local user.name "Auto Update Bot"
    git commit --author "Auto Update Bot <>" -m "$(date)"
    git push origin master
}

echo "Fetching remote repository"
fetch_remote_repository
echo "Computing checksums"
fetch_cached_checksum
compute_remote_checksum
print_checksums

exit_if_no_changes

echo "Remote version difference detected"
echo "Copying new data"
copy_data
cleanup_remote_repository

echo "Validating YAML files"
validate_yaml_data

echo "Verifying new checksum"
compute_local_checksumm
print_checksums
if [ "$LOCAL_COPY_SHA" != "$REMOTE_COPY_SHA" ]; then unknown_error; fi
cache_local_checksum

# Convert the YAML files to JSON
echo "Converting YAML to JSON"
convert_yaml_to_json

# This checks if the data format was radically changed or one of the
# operations above has failed
echo "Validating JSON files"
validate_json_data

# Commit the new changes
echo "Comitting changes"
commit_changes

cleanup_remote_repository
