-- Let the uploader remove a clinical attachment from mockup 13. Access to the
-- consultation is checked as well so a path cannot be used outside its case.

drop policy if exists baseline_storage_consultation_delete on storage.objects;
create policy baseline_storage_consultation_delete on storage.objects
for delete to authenticated
using (
  bucket_id = 'consultation-docs'
  and (storage.foldername(name))[1] = auth.uid()::text
  and public.can_access_consultation(
    nullif((storage.foldername(name))[2], '')::bigint
  )
);
