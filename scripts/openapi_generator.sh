#!/bin/bash

CUR_PATH=`dirname ${BASH_SOURCE[0]}`

openapi-generator generate \
    -i $CUR_PATH/../.well-known/openapi.yaml \
    -g julia-server \
    -o $CUR_PATH/../src/generated \
    --additional-properties=packageName=GptPluginServer \
    --additional-properties=exportModels=true
