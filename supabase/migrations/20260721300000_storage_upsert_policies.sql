-- Storage uploads made with upsert=true need SELECT and UPDATE in addition to
-- INSERT. The Flutter client uses upsert for profile and pet photos.

drop policy if exists baseline_storage_profiles_select_own on storage.objects;
create policy baseline_storage_profiles_select_own on storage.objects
for select to authenticated
using (
  bucket_id = 'profiles'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists baseline_storage_profiles_update on storage.objects;
create policy baseline_storage_profiles_update on storage.objects
for update to authenticated
using (
  bucket_id = 'profiles'
  and (storage.foldername(name))[2] = auth.uid()::text
)
with check (
  bucket_id = 'profiles'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists baseline_storage_profiles_delete_own on storage.objects;
create policy baseline_storage_profiles_delete_own on storage.objects
for delete to authenticated
using (
  bucket_id = 'profiles'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists baseline_storage_pet_select_own on storage.objects;
create policy baseline_storage_pet_select_own on storage.objects
for select to authenticated
using (
  bucket_id = 'pet-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists baseline_storage_pet_update on storage.objects;
create policy baseline_storage_pet_update on storage.objects
for update to authenticated
using (
  bucket_id = 'pet-images'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'pet-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists baseline_storage_pet_delete_own on storage.objects;
create policy baseline_storage_pet_delete_own on storage.objects
for delete to authenticated
using (
  bucket_id = 'pet-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);
