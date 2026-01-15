<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Upload Limits
    |--------------------------------------------------------------------------
    |
    | Define file size limits and allowed types for media uploads
    |
    */

    'max_file_size' => env('MEDIA_MAX_FILE_SIZE', 10 * 1024 * 1024), // 10MB default

    'allowed_mime_types' => [
        'image/jpeg',
        'image/jpg',
        'image/png',
        'image/webp',
        'image/heic',
        'image/heif',
    ],

    'allowed_extensions' => [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'heic',
        'heif',
    ],

    /*
    |--------------------------------------------------------------------------
    | S3 Upload Configuration
    |--------------------------------------------------------------------------
    |
    | Security and performance settings for S3 uploads
    |
    */

    'presigned_url_expiry' => env('MEDIA_PRESIGNED_URL_EXPIRY', 900), // 15 minutes

    's3_upload_options' => [
        'ACL' => 'private', // Objects are private by default
        'ServerSideEncryption' => 'AES256', // Encrypt at rest
    ],

    /*
    |--------------------------------------------------------------------------
    | Rate Limiting
    |--------------------------------------------------------------------------
    |
    | Throttle upload requests to prevent abuse
    |
    */

    'rate_limit' => [
        'max_attempts' => env('MEDIA_RATE_LIMIT_ATTEMPTS', 20),
        'decay_minutes' => env('MEDIA_RATE_LIMIT_DECAY', 1),
    ],

    /*
    |--------------------------------------------------------------------------
    | Cleanup
    |--------------------------------------------------------------------------
    |
    | Cleanup settings for orphaned uploads
    |
    */

    'cleanup_pending_after_hours' => env('MEDIA_CLEANUP_PENDING_HOURS', 24),
];
