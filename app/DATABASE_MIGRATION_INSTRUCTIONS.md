# VetCare Database Migration Instructions

## Required Migration: Add Document Column

### Issue
The app throws an error "Could not find the 'document' column of 'users'" when trying to edit user profiles.

### Solution
Execute this SQL in your Supabase SQL Editor:

```sql
-- Add document column to users table if it doesn't exist
ALTER TABLE IF EXISTS users 
ADD COLUMN IF NOT EXISTS document text;

-- Create an index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_document ON users(document);
```

### Steps
1. Go to your Supabase project
2. Click on "SQL Editor" in the left menu
3. Click "New Query"
4. Copy and paste the SQL above
5. Click "Run"

### Verification
After running, try editing a user profile - the error should be gone.

---

## Database Schema Notes

The users table should now have:
- id (UUID, primary key)
- email (text, unique)
- first_name (text)
- last_name (text)
- phone (text, optional)
- document (text, optional) ✅ **NEW**
- address (text, optional)
- profile_picture (text, optional)
- latitude (double precision, optional)
- longitude (double precision, optional)
- role (user_role enum: 'client' | 'veterinarian')
- created_at (timestamptz)
