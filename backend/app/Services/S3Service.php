<?php

namespace App\Services;

use Aws\S3\S3Client;
use Illuminate\Support\Facades\Log;

class S3Service
{
    private static ?S3Client $client = null;

    /**
     * Get singleton S3Client instance
     */
    public static function getClient(): S3Client
    {
        if (self::$client === null) {
            self::$client = new S3Client([
                'version' => 'latest',
                'region' => config('filesystems.disks.s3.region'),
                'credentials' => [
                    'key' => config('filesystems.disks.s3.key'),
                    'secret' => config('filesystems.disks.s3.secret'),
                ],
            ]);
        }

        return self::$client;
    }

    /**
     * Generate presigned PUT URL for file upload
     *
     * @param string $key S3 object key
     * @param int $expirySeconds Expiry time in seconds
     * @param array $options Additional options (ACL, ServerSideEncryption, etc.)
     * @return string Presigned URL
     */
    public static function generatePresignedPutUrl(
        string $key,
        int $expirySeconds = 900,
        array $options = []
    ): string {
        $client = self::getClient();

        $commandParams = array_merge([
            'Bucket' => config('filesystems.disks.s3.bucket'),
            'Key' => $key,
        ], $options);

        $command = $client->getCommand('PutObject', $commandParams);
        $presignedRequest = $client->createPresignedRequest(
            $command,
            "+{$expirySeconds} seconds"
        );

        return (string) $presignedRequest->getUri();
    }

    /**
     * Check if an object exists in S3
     *
     * @param string $key S3 object key
     * @return bool
     */
    public static function objectExists(string $key): bool
    {
        try {
            $client = self::getClient();
            $client->headObject([
                'Bucket' => config('filesystems.disks.s3.bucket'),
                'Key' => $key,
            ]);
            return true;
        } catch (\Aws\S3\Exception\S3Exception $e) {
            if ($e->getStatusCode() === 404) {
                return false;
            }
            Log::error('S3 objectExists check failed', [
                'key' => $key,
                'error' => $e->getMessage(),
            ]);
            throw $e;
        }
    }

    /**
     * Get object metadata
     *
     * @param string $key S3 object key
     * @return array|null
     */
    public static function getObjectMetadata(string $key): ?array
    {
        try {
            $client = self::getClient();
            $result = $client->headObject([
                'Bucket' => config('filesystems.disks.s3.bucket'),
                'Key' => $key,
            ]);

            return [
                'size' => $result['ContentLength'] ?? null,
                'content_type' => $result['ContentType'] ?? null,
                'etag' => $result['ETag'] ?? null,
                'last_modified' => $result['LastModified'] ?? null,
            ];
        } catch (\Aws\S3\Exception\S3Exception $e) {
            Log::error('S3 getObjectMetadata failed', [
                'key' => $key,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Generate presigned GET URL for file download
     *
     * @param string $key S3 object key
     * @param int $expirySeconds Expiry time in seconds
     * @return string Presigned URL
     */
    public static function generatePresignedGetUrl(
        string $key,
        int $expirySeconds = 900
    ): string {
        $client = self::getClient();

        $command = $client->getCommand('GetObject', [
            'Bucket' => config('filesystems.disks.s3.bucket'),
            'Key' => $key,
        ]);

        $presignedRequest = $client->createPresignedRequest(
            $command,
            "+{$expirySeconds} seconds"
        );

        return (string) $presignedRequest->getUri();
    }
}
