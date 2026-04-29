-- Run this in the Supabase SQL Editor for the project used by the backend.
-- The app uploads and reads files through the Node backend with the service role key.
-- No storage.objects RLS policy is required for this backend-mediated flow.
-- The application database is local, so app table changes live in database/migrations.

INSERT INTO storage.buckets (
    id,
    name,
    public,
    file_size_limit,
    allowed_mime_types
)
VALUES (
    'omniconnect-documents',
    'omniconnect-documents',
    false,
    10485760,
    ARRAY[
        'application/pdf',
        'image/png',
        'image/jpeg',
        'image/heic',
        'image/heif',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    ]::text[]
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;
