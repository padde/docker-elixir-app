#!/bin/bash

# Export tool version vars from .tool-versions
while read -r line; do
  IFS=" " read -ra parts <<< "$line"
  tool_name=$(awk '{print toupper($0)}' <<< "${parts[0]}")
  tool_version=${parts[1]}
  export "${tool_name}_VERSION=$tool_version"
done < .tool-versions

APP_NAME=$(grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')
export APP_NAME

APP_VERSION=$(grep 'version:' mix.exs | cut -d '"' -f2)
export APP_VERSION

BUILD=$(git rev-parse --short HEAD)
export BUILD
