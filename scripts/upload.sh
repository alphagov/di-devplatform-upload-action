#! /bin/bash

echo "Parsing resources to be signed"
RESOURCES="$(yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::Function") | path | .[1]' "$TEMPLATE_FILE" | xargs)"
read -ra LIST <<< "$RESOURCES"

echo "Packaging SAM app"
PROFILES=("${LIST[@]/%/="$SIGNING_PROFILE"}")
sam package --s3-bucket="$ARTIFACT_BUCKET" --output-template-file=cf-template.yaml --signing-profiles "${PROFILES[*]}"

echo "Writing Lambda provenance"
./write-lambda-provenance.sh

echo "Zipping the CloudFormation template"
zip template.zip cf-template.yaml

echo "Uploading zipped CloudFormation artifact to S3"
aws s3 cp template.zip "s3://$ARTIFACT_BUCKET/template.zip" --metadata "repository=$GITHUB_REPOSITORY,commitsha=$GITHUB_SHA"