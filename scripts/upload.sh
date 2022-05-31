#! /bin/bash

set -eu

echo "Parsing resources to be signed"
RESOURCES="$(yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::Function") | path | .[1]' "$TEMPLATE_FILE" | xargs)"
read -ra LIST <<< "$RESOURCES"
PROFILES=("${LIST[@]/%/="$SIGNING_PROFILE"}")
if [ "${#PROFILES[@]}" -eq 0 ]
then
  echo "No resources that require signing found"
  exit 1
fi

echo "Packaging SAM app"
sam package --s3-bucket="$ARTIFACT_BUCKET" --output-template-file=cf-template.yaml --signing-profiles "${PROFILES[*]}"

echo "Writing Lambda provenance"
yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::Function") | .Properties.CodeUri' cf-template.yaml \
    | xargs -L1 -I{} aws s3 cp "{}" "{}" --metadata "repository=$GITHUB_REPOSITORY,commitsha=$GITHUB_SHA"

echo "Zipping the CloudFormation template"
zip template.zip cf-template.yaml

echo "Uploading zipped CloudFormation artifact to S3"
aws s3 cp template.zip "s3://$ARTIFACT_BUCKET/template.zip" --metadata "repository=$GITHUB_REPOSITORY,commitsha=$GITHUB_SHA"