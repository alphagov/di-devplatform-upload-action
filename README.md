# Upload Action

This is an action that allows you to upload a built SAM application to S3 using GitHub Actions.

The action packages, signs the Lambda functions, and uploads the application to the specified S3 bucket.

## Action Inputs

| Input                | Required | Description                                                                     | Example              |
|----------------------|----------|---------------------------------------------------------------------------------|----------------------|
| artifact-bucket-name | true     | The name of the artifact S3 bucket                                              | artifact-bucket-1234 |
| signing-profile-name | true     | The name of the Signing Profile resource in AWS                                 | signing-profile-1234 |
| working-directory    | true     | The working directory containing the SAM app and the template file              | ./sam-app            |
| template-file        | false    | The name of the CF template for the application. This defaults to template.yaml | custom-template.yaml |

## Usage Example

Pull in the action in your workflow as below, making sure to specify the release version you require.

```yaml
- name: Deploy SAM app
  uses: alphagov/di-devplatform-upload-action@<version_number>
  with:
    artifact-bucket-name: ${{ secrets.ARTIFACT_BUCKET_NAME }}
    signing-profile-name: ${{ secrets.SIGNING_PROFILE_NAME }}
    working-directory: ./sam-app
    template-file: custom-template.yaml
```

## Requirements

- pre-commit:

  ```shell
  brew install pre-commit
  pre-commit install -tpre-commit -tprepare-commit-msg -tcommit-msg
  ```

## Releasing updates

We
follow [recommended best practices](https://docs.github.com/en/actions/creating-actions/releasing-and-maintaining-actions)
for releasing new versions of the action.

### Non-breaking changes

Release a new minor or patch version as appropriate, then update the base major version release (and any minor versions)
to point to this latest appropriate commit. e.g.: If the latest major release is v2, and you have added a non-breaking
feature, release v2.1.0 and point v2 to the same commit as v2.1.0.

NOTE: Until v3 is released, you will need to point both v1 and v2 to the latest version since there are no breaking changes between them.

### Breaking changes

Release a new major version as normal following semantic versioning.