-- Prevent role escalation through editable auth user_metadata or direct table
-- writes. Roles are accepted only at account creation; later auth updates may
-- synchronize the email but cannot change the application role.

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

create or replace function public.sync_auth_user_email()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.users set email = coalesce(new.email, email) where id = new.id;
  return new;
end;
$$;

drop trigger if exists on_auth_user_email_changed on auth.users;
create trigger on_auth_user_email_changed
  after update of email on auth.users
  for each row
  when (old.email is distinct from new.email)
  execute function public.sync_auth_user_email();

-- A profile owner may edit contact fields, never id/email/role.
revoke update on public.users from authenticated;
grant update (
  first_name, last_name, phone, document, address, profile_picture,
  latitude, longitude
) on public.users to authenticated;

-- Role-specific rows are created by the auth trigger and cannot be deleted by
-- client applications.
revoke insert, delete on public.clients from authenticated;
grant select, update on public.clients to authenticated;

-- Booking and reviews must use the validated security-definer RPCs.
revoke insert, delete on public.consultations from authenticated;
grant select, update on public.consultations to authenticated;
revoke insert, update, delete on public.reviews from authenticated;
grant select on public.reviews to authenticated;

revoke execute on function public.handle_new_auth_user() from public, anon, authenticated;
revoke execute on function public.sync_auth_user_email() from public, anon, authenticated;
