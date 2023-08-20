# Scaleway

Cheaper and French clone of AWS S3.

## Configure locally

- install the AWS CLI
- create a Scaleway profile 

Read: https://www.scaleway.com/en/docs/storage/object/api-cli/object-storage-aws-cli/#how-to-install-the-aws-cli

## Create a bucket

Visit: https://console.scaleway.com/object-storage/buckets/create

## Update the CORS for the Rails Direct upload feature

Within the `docs/scaleway` folder:

```bash
aws s3api --profile=scaleway put-bucket-cors --bucket poolpybot-development --cors-configuration file://cors.json
```

For the **production** environment:

```bash
aws s3api --profile=scaleway put-bucket-cors --bucket poolpybot-production --cors-configuration file://cors.json
```
