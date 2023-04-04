#! /bin/bash

set -eu

echo "Parsing resources to be signed"
RESOURCES="$(yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::Function" or .Type == "AWS::Serverless::LayerVersion") | path | .[1]' "$TEMPLATE_FILE" | xargs)"
read -ra LIST <<< "$RESOURCES"

# Construct the signing-profiles argument list
# e.g.: (HelloWorldFunction1="signing-profile-name" HelloWorldFunction2="signing-profile-name")
PROFILES=("${LIST[@]/%/="$SIGNING_PROFILE"}")

echo "Packaging SAM app"
if [ "${#PROFILES[@]}" -eq 0 ]
then
  echo "No resources that require signing found"
  sam package --s3-bucket="$ARTIFACT_BUCKET" --output-template-file=cf-template.yaml
else
  sam package --s3-bucket="$ARTIFACT_BUCKET" --output-template-file=cf-template.yaml --signing-profiles "${PROFILES[*]}"
fi

# This only gets set if there is a tag on the current commit.
GIT_TAG=$(git describe --tags --first-parent --always)

echo "Writing Lambda provenance"
yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::Function") | .Properties.CodeUri' cf-template.yaml \
    | xargs -L1 -I{} aws s3 cp "{}" "{}" --metadata "repository=$GITHUB_REPOSITORY,commitsha=$GITHUB_SHA,commitmessage=$COMMIT_MESSAGE,committag=$GIT_TAG"
echo "Writing Lambda Layer provenance"
yq '.Resources.* | select(has("Type") and .Type == "AWS::Serverless::LayerVersion") | .Properties.ContentUri' cf-template.yaml \
    | xargs -L1 -I{} aws s3 cp "{}" "{}" --metadata "repository=$GITHUB_REPOSITORY,commitsha=$GITHUB_SHA,commitmessage=$COMMIT_MESSAGE,committag=$GIT_TAG"

echo "Zipping the CloudFormation template"
zip template.zip cf-template.yaml

echo "Uploading zipped CloudFormation artifact to S3"
aws s3 cp template.zip "s3://$ARTIFACT_BUCKET/template.zip" --metadata "repository=$GITHUB_REPOSITORY,commitsha=$GITHUB_SHA,commitmessage=$COMMIT_MESSAGE,author=,committag="
