-- VetCare security hardening.
-- Keeps internal failures private, limits veterinarian access to assigned
-- patients, and makes PostgREST privileges explicit while RLS remains the
-- final authorization layer.

create or replace function public.veterinarian_can_access_pet(p_pet_id bigint)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.consultations c
    join public.veterinarians v on v.id = c.veterinarian_id
    where c.pet_id = p_pet_id
      and v.user_id = auth.uid()
      and v.is_active
  );
$$;

create or replace function public.can_view_profile(p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    p_user_id = auth.uid()
    or exists (
      select 1
      from public.veterinarians target_vet
      where target_vet.user_id = p_user_id and target_vet.is_active
    )
    or exists (
      select 1
      from public.consultations c
      join public.pets p on p.id = c.pet_id
      join public.veterinarians current_vet on current_vet.id = c.veterinarian_id
      where p.client_id = p_user_id
        and current_vet.user_id = auth.uid()
        and current_vet.is_active
    );
$$;

drop policy if exists baseline_users_select on public.users;
create policy baseline_users_select on public.users for select to authenticated
  using (public.can_view_profile(id));

drop policy if exists baseline_pets_access on public.pets;
create policy baseline_pets_access on public.pets for select to authenticated
  using (client_id = auth.uid() or public.veterinarian_can_access_pet(id));

drop policy if exists baseline_morphological_access on public.morphological_records;
create policy baseline_morphological_access on public.morphological_records for select to authenticated
  using (public.owns_pet(pet_id) or public.veterinarian_can_access_pet(pet_id));

drop policy if exists baseline_morphological_write on public.morphological_records;
create policy baseline_morphological_write on public.morphological_records for all to authenticated
  using (public.owns_pet(pet_id) or public.veterinarian_can_access_pet(pet_id))
  with check (public.owns_pet(pet_id) or public.veterinarian_can_access_pet(pet_id));

drop policy if exists baseline_legal_documents_access on public.legal_documents;
create policy baseline_legal_documents_access on public.legal_documents for select to authenticated
  using (public.owns_pet(pet_id) or public.veterinarian_can_access_pet(pet_id));

drop policy if exists baseline_storage_legal_access on storage.objects;
create policy baseline_storage_legal_access on storage.objects for select to authenticated
  using (
    bucket_id = 'legal-docs'
    and (
      public.owns_pet(nullif((storage.foldername(name))[2], '')::bigint)
      or public.veterinarian_can_access_pet(nullif((storage.foldername(name))[2], '')::bigint)
    )
  );

-- PostgREST needs SQL privileges in addition to RLS policies.
grant usage on schema public to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage, select on all sequences in schema public to authenticated;
grant select on public.species, public.breeds, public.specialties,
  public.veterinarians, public.veterinarian_specialties to anon;

-- Functions are executable by PUBLIC unless that implicit privilege is
-- revoked. Mutating RPCs are restricted to authenticated JWTs.
revoke execute on function public.book_consultation(bigint, uuid, bigint, timestamptz, text) from public, anon;
revoke execute on function public.start_consultation(bigint) from public, anon;
revoke execute on function public.complete_consultation(bigint, text, text, text, boolean, jsonb, jsonb) from public, anon;
revoke execute on function public.submit_review(bigint, integer, text) from public, anon;
revoke execute on function public.available_slots(uuid, date) from public, anon;
revoke execute on function public.owns_pet(bigint) from public, anon;
revoke execute on function public.can_access_consultation(bigint) from public, anon;
revoke execute on function public.is_veterinarian() from public, anon;
revoke execute on function public.veterinarian_can_access_pet(bigint) from public, anon;
revoke execute on function public.can_view_profile(uuid) from public, anon;

grant execute on function public.book_consultation(bigint, uuid, bigint, timestamptz, text) to authenticated;
grant execute on function public.start_consultation(bigint) to authenticated;
grant execute on function public.complete_consultation(bigint, text, text, text, boolean, jsonb, jsonb) to authenticated;
grant execute on function public.submit_review(bigint, integer, text) to authenticated;
grant execute on function public.available_slots(uuid, date) to authenticated;
grant execute on function public.owns_pet(bigint) to authenticated;
grant execute on function public.can_access_consultation(bigint) to authenticated;
grant execute on function public.is_veterinarian() to authenticated;
grant execute on function public.veterinarian_can_access_pet(bigint) to authenticated;
grant execute on function public.can_view_profile(uuid) to authenticated;
