# Upload Action

This is an action that allows you to upload a built SAM application to S3 using GitHub Actions.

The action packages and uploads the application and adds provenance metadata to

## Action Inputs

| Input                | Required | Description                                                                     | Example              |
|----------------------|----------|---------------------------------------------------------------------------------|----------------------|
| artifact-bucket-name | true     | The name of the artifact S3 bucket                                              | artifact-bucket-1234 |
| signing-profile-name | true     | The name of the Signing Profile resource in AWS                                 | signing-profile-1234 |
| working-directory    | true     | The working directory containing the SAM app and the template file              | ./sam-app            |
| template-file        | false    | The name of the CF template for the application. This defaults to template.yaml | custom-template.yaml |

## Usage Example

```yaml
- name: Deploy SAM app
  uses: alphagov/di-devplatform-upload-action@v1
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
