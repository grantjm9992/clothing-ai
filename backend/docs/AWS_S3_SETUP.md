# AWS S3 Setup for Production

This document outlines the required AWS S3 configuration for the Clothing AI backend.

## 1. S3 Bucket Configuration

### Bucket Settings
- **Bucket Name**: `clothing-ai` (or your configured bucket name)
- **Region**: `eu-west-3` (or your configured region)
- **Block Public Access**: Keep all public access blocked (objects accessed via presigned URLs)

### Versioning
Enable versioning for backup and recovery:
```bash
aws s3api put-bucket-versioning \
  --bucket clothing-ai \
  --versioning-configuration Status=Enabled
```

### Encryption
Enable default server-side encryption (AES256):
```bash
aws s3api put-bucket-encryption \
  --bucket clothing-ai \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

## 2. CORS Configuration

The bucket **MUST** have CORS enabled for browser uploads. Apply this configuration:

```json
[
  {
    "AllowedOrigins": [
      "http://localhost:*",
      "https://yourdomain.com",
      "https://*.yourdomain.com"
    ],
    "AllowedMethods": [
      "GET",
      "PUT",
      "POST"
    ],
    "AllowedHeaders": [
      "*"
    ],
    "ExposeHeaders": [
      "ETag",
      "x-amz-server-side-encryption",
      "x-amz-request-id"
    ],
    "MaxAgeSeconds": 3000
  }
]
```

Apply via AWS CLI:
```bash
aws s3api put-bucket-cors \
  --bucket clothing-ai \
  --cors-configuration file://cors-config.json
```

Or via AWS Console:
1. Go to S3 → Select bucket → Permissions tab
2. Scroll to CORS section
3. Click Edit and paste the JSON above

## 3. Bucket Policy

For production, objects should be private by default. Access is granted via presigned URLs:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyInsecureConnections",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::clothing-ai",
        "arn:aws:s3:::clothing-ai/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

This policy enforces HTTPS for all connections.

Apply via AWS CLI:
```bash
aws s3api put-bucket-policy \
  --bucket clothing-ai \
  --policy file://bucket-policy.json
```

## 4. Lifecycle Policy (Optional)

Clean up incomplete multipart uploads and old versions:

```json
{
  "Rules": [
    {
      "Id": "DeleteIncompleteMultipartUploads",
      "Status": "Enabled",
      "AbortIncompleteMultipartUpload": {
        "DaysAfterInitiation": 1
      }
    },
    {
      "Id": "DeleteOldVersions",
      "Status": "Enabled",
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 30
      }
    }
  ]
}
```

Apply via AWS CLI:
```bash
aws s3api put-bucket-lifecycle-configuration \
  --bucket clothing-ai \
  --lifecycle-configuration file://lifecycle-policy.json
```

## 5. IAM User Permissions

Your IAM user needs these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:HeadObject"
      ],
      "Resource": [
        "arn:aws:s3:::clothing-ai",
        "arn:aws:s3:::clothing-ai/*"
      ]
    }
  ]
}
```

## 6. CloudFront CDN (Recommended)

For better performance and reduced S3 costs, use CloudFront:

1. Create a CloudFront distribution
2. Set Origin to your S3 bucket
3. Use Origin Access Identity (OAI) for security
4. Update `.env` with CloudFront domain:
   ```env
   AWS_CLOUDFRONT_URL=https://dxxxxx.cloudfront.net
   ```

## 7. Monitoring & Alerts

Set up CloudWatch alarms for:
- **High request rates**: Alert if PUT requests exceed threshold
- **4xx/5xx errors**: Alert on authentication or server errors
- **Bucket size**: Monitor storage growth

## 8. Cost Optimization

- Enable **S3 Intelligent-Tiering** for automatic cost optimization
- Use **CloudFront** to reduce S3 GET requests
- Set up **S3 Storage Lens** for usage analytics
- Consider **S3 Transfer Acceleration** for faster uploads from distant regions

## Environment Variables

Ensure these are set in `.env`:

```env
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key
AWS_DEFAULT_REGION=eu-west-3
AWS_BUCKET=clothing-ai

# Optional
AWS_CLOUDFRONT_URL=https://your-distribution.cloudfront.net
MEDIA_MAX_FILE_SIZE=10485760  # 10MB in bytes
MEDIA_PRESIGNED_URL_EXPIRY=900  # 15 minutes
```

## Verification

Test your configuration:

```bash
# 1. Test presigned URL generation
curl -X POST http://localhost:8000/api/v1/media/presign \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "outfit_photo",
    "mimeType": "image/jpeg",
    "fileName": "test.jpg",
    "fileSize": 1024
  }'

# 2. Upload a test file using the presigned URL
curl -X PUT "PRESIGNED_URL_FROM_STEP_1" \
  -H "Content-Type: image/jpeg" \
  --data-binary "@test.jpg"

# 3. Complete the upload
curl -X POST http://localhost:8000/api/v1/media/complete \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "mediaObjectId": "MEDIA_OBJECT_ID_FROM_STEP_1",
    "width": 1920,
    "height": 1080
  }'
```

## Security Checklist

- [ ] Block all public access enabled
- [ ] CORS configured for your domains only
- [ ] Bucket policy enforces HTTPS
- [ ] IAM user has minimum required permissions
- [ ] Server-side encryption enabled
- [ ] Versioning enabled
- [ ] Lifecycle policies configured
- [ ] CloudWatch monitoring active
- [ ] Access keys rotated regularly (90 days)
- [ ] MFA enabled on AWS account

## Troubleshooting

### SignatureDoesNotMatch Error
- Verify AWS credentials match in .env
- Ensure region matches bucket location
- Check that no AWS_ENDPOINT is set for AWS S3
- Verify system clock is accurate (signature requires correct time)

### CORS Error
- Verify CORS configuration includes your domain
- Check that AllowedHeaders includes "*"
- Ensure AllowedMethods includes "PUT"

### 403 Forbidden
- Verify IAM permissions include s3:PutObject
- Check bucket policy doesn't deny access
- Ensure presigned URL hasn't expired

### File Not Found After Upload
- Verify upload completed successfully (check response status)
- Check bucket name and region are correct
- Verify storage key path is correct
