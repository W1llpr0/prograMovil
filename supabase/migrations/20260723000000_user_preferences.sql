-- Persist per-user UI preferences in Supabase so they follow the account
-- across devices. SharedPreferences remains only a pre-login local cache.

create table if not exists public.user_preferences (
  user_id uuid primary key references public.users(id) on delete cascade,
  locale text not null default 'es' check (locale in ('es', 'en')),
  dark_mode boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into public.user_preferences (user_id)
select id from public.users
on conflict (user_id) do nothing;

create or replace function public.create_default_user_preferences()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_preferences (user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_public_user_preferences_created on public.users;
create trigger on_public_user_preferences_created
  after insert on public.users
  for each row execute function public.create_default_user_preferences();

drop trigger if exists trg_user_preferences_updated_at
  on public.user_preferences;
create trigger trg_user_preferences_updated_at
  before update on public.user_preferences
  for each row execute function public.set_updated_at();

alter table public.user_preferences enable row level security;

drop policy if exists user_preferences_select_own
  on public.user_preferences;
create policy user_preferences_select_own
  on public.user_preferences for select to authenticated
  using (user_id = auth.uid());

drop policy if exists user_preferences_insert_own
  on public.user_preferences;
create policy user_preferences_insert_own
  on public.user_preferences for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists user_preferences_update_own
  on public.user_preferences;
create policy user_preferences_update_own
  on public.user_preferences for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

grant select, insert, update on public.user_preferences to authenticated;
revoke delete on public.user_preferences from authenticated;
revoke execute on function public.create_default_user_preferences()
  from public, anon, authenticated;
