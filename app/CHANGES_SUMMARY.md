# VetCare App - Changes Summary

## ✅ COMPLETED CHANGES

### 1. Database & Profile Issues
- **Added document column migration** (`DATABASE_MIGRATION_INSTRUCTIONS.md`)
  - Instructions to run SQL in Supabase to add missing `document` column
  - Creates index for performance
- **Fixed profile placeholders** - Changed "Not set" to empty strings
- **Implemented profile picture upload**
  - User can tap the "+" button to upload/change profile picture
  - Picture stores in Supabase `profiles` storage bucket
  - Display uploaded photo in avatar with fallback to initials

### 2. Pet Creation Form Improvements
- **Date picker for birth date** 
  - Replaced text input with calendar picker
  - Shows MM/YYYY format
  - User can select any date or just year/month
- **Weight field marked as optional**
  - Visual "Optional" label below WEIGHT (KG)
  - Validation allows empty weight
- **Sex selector expanded**
  - Added "Unknown" option (Unknown/Male/Female)
  - Better for species where sex is hard to determine
- **Dynamic species loading**
  - Species buttons load from API instead of hardcoded list
  - All species from database are now selectable

### 3. Form Field Labels
- Changed "FULL NAME" → "NAME" for clearer labeling
- Fixed all label and placeholder text

---

## ⚠️ PENDING ITEMS (Requires Your Action)

### 1. **DATABASE MIGRATION** (CRITICAL)
You need to run SQL in Supabase to add the `document` column:

1. Go to your Supabase project
2. Click "SQL Editor" → "New Query"
3. Paste the SQL from `DATABASE_MIGRATION_INSTRUCTIONS.md`
4. Click "Run"

Without this, profile editing will fail with "column 'document' not found" error.

### 2. **BREED API** (Not Implemented)
Currently breed is just a text field. To add breed suggestions based on species:
- You would need an API or database table with breeds
- Example: Select "Dog" → get list of "Golden Retriever, Labrador, etc."
- Can be added in future iteration

### 3. **MAP** (Placeholder)
The epidemiological map page shows a placeholder. To add real maps:
- Integrate Google Maps or Mapbox
- Requires API key configuration
- Can be added in future iteration

### 4. **REGISTER PET BUTTON**
The button should work now - it calls `ctrl.submit()` → `ctrl.savePet()`
- Verify pet is saved by checking app database/dashboard
- If not working, check that species is selected and form is valid

---

## 📝 FILE CHANGES
- `lib/pages/profile/profile_page.dart` - Profile picture display + placeholder fixes
- `lib/pages/profile/profile_controller.dart` - Added photo upload functionality
- `lib/pages/add_pet/add_pet_page.dart` - Date picker + sex options + weight optional
- `lib/pages/add_pet/add_pet_controller.dart` - Updated sex handling
- `lib/pages/sign_up/sign_up_page.dart` - Changed FULL NAME → NAME
- `lib/services/auth_service.dart` - Added document field support
- `migrations/add_document_column.sql` - SQL migration file
- `DATABASE_MIGRATION_INSTRUCTIONS.md` - Migration guide

---

## 🚀 Next Steps

1. **Execute the SQL migration** (see above)
2. **Test the app**:
   - Create a new account with DNI
   - Edit profile picture
   - Create pet with date picker
   - Verify Register Pet button works
3. **Future improvements**:
   - Add breed API/database
   - Integrate real map
   - Add more species details

---

## 💡 Database Notes

All data is being stored in Supabase:
- User profiles in `users` table (with new `document` column)
- Profile pictures in `profiles` storage bucket
- Pets in `pets` table with species from `species` table
- Sex stored as NULL for "Unknown" or 'M'/'F' codes
