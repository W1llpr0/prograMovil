-- Migration: Add document column to users table
-- This migration adds the 'document' column which was missing from the schema

-- Check if column exists, if not, add it
ALTER TABLE IF EXISTS users 
ADD COLUMN IF NOT EXISTS document text;

-- Optional: Create an index on document for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_document ON users(document);
