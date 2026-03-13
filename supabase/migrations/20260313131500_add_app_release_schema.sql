create extension if not exists pgcrypto with schema extensions;

create table if not exists public.resumes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  summary text not null default '',
  experience_bullets jsonb not null default '[]'::jsonb,
  skills jsonb not null default '[]'::jsonb,
  education text not null default '',
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists resumes_user_created_idx
  on public.resumes (user_id, created_at desc);

alter table public.resumes enable row level security;

drop policy if exists resumes_select_own on public.resumes;
create policy resumes_select_own
on public.resumes
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists resumes_insert_own on public.resumes;
create policy resumes_insert_own
on public.resumes
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists resumes_delete_own on public.resumes;
create policy resumes_delete_own
on public.resumes
for delete
to authenticated
using ((select auth.uid()) = user_id);


create table if not exists public.cover_letters (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  cover_letter text not null default '',
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists cover_letters_user_created_idx
  on public.cover_letters (user_id, created_at desc);

alter table public.cover_letters enable row level security;

drop policy if exists cover_letters_select_own on public.cover_letters;
create policy cover_letters_select_own
on public.cover_letters
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists cover_letters_insert_own on public.cover_letters;
create policy cover_letters_insert_own
on public.cover_letters
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists cover_letters_delete_own on public.cover_letters;
create policy cover_letters_delete_own
on public.cover_letters
for delete
to authenticated
using ((select auth.uid()) = user_id);


create table if not exists public.interview_sets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  technical_questions jsonb not null default '[]'::jsonb,
  behavioral_questions jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists interview_sets_user_created_idx
  on public.interview_sets (user_id, created_at desc);

alter table public.interview_sets enable row level security;

drop policy if exists interview_sets_select_own on public.interview_sets;
create policy interview_sets_select_own
on public.interview_sets
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists interview_sets_insert_own on public.interview_sets;
create policy interview_sets_insert_own
on public.interview_sets
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists interview_sets_delete_own on public.interview_sets;
create policy interview_sets_delete_own
on public.interview_sets
for delete
to authenticated
using ((select auth.uid()) = user_id);


insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'cv-uploads',
  'cv-uploads',
  false,
  10485760,
  array['application/pdf']
)
on conflict (id) do nothing;

drop policy if exists cv_uploads_select_own on storage.objects;
create policy cv_uploads_select_own
on storage.objects
for select
to authenticated
using (
  bucket_id = 'cv-uploads'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists cv_uploads_insert_own on storage.objects;
create policy cv_uploads_insert_own
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'cv-uploads'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists cv_uploads_update_own on storage.objects;
create policy cv_uploads_update_own
on storage.objects
for update
to authenticated
using (
  bucket_id = 'cv-uploads'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'cv-uploads'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);


create table if not exists public.uploaded_cvs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  file_name text not null,
  storage_bucket text not null default 'cv-uploads',
  storage_path text not null,
  mime_type text not null default 'application/pdf',
  file_size_bytes integer not null default 0,
  parsing_status text not null default 'processing'
    check (parsing_status in ('processing', 'parsed', 'failed')),
  parsing_error text,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists uploaded_cvs_user_created_idx
  on public.uploaded_cvs (user_id, created_at desc);

alter table public.uploaded_cvs enable row level security;

drop policy if exists uploaded_cvs_select_own on public.uploaded_cvs;
create policy uploaded_cvs_select_own
on public.uploaded_cvs
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists uploaded_cvs_insert_own on public.uploaded_cvs;
create policy uploaded_cvs_insert_own
on public.uploaded_cvs
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists uploaded_cvs_update_own on public.uploaded_cvs;
create policy uploaded_cvs_update_own
on public.uploaded_cvs
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);


create table if not exists public.candidate_profiles (
  id uuid primary key default gen_random_uuid(),
  uploaded_cv_id uuid not null unique references public.uploaded_cvs(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null default '',
  email text not null default '',
  location text not null default '',
  years_experience integer not null default 0 check (years_experience >= 0),
  roles jsonb not null default '[]'::jsonb,
  skills jsonb not null default '[]'::jsonb,
  industries jsonb not null default '[]'::jsonb,
  seniority text not null default '',
  education text not null default '',
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists candidate_profiles_user_created_idx
  on public.candidate_profiles (user_id, created_at desc);

alter table public.candidate_profiles enable row level security;

drop policy if exists candidate_profiles_select_own on public.candidate_profiles;
create policy candidate_profiles_select_own
on public.candidate_profiles
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists candidate_profiles_insert_own on public.candidate_profiles;
create policy candidate_profiles_insert_own
on public.candidate_profiles
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists candidate_profiles_update_own on public.candidate_profiles;
create policy candidate_profiles_update_own
on public.candidate_profiles
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);


create table if not exists public.usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  feature text not null,
  reservation_key text not null,
  status text not null check (status in ('pending', 'succeeded')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (user_id, reservation_key)
);

create index if not exists usage_events_user_created_idx
  on public.usage_events (user_id, created_at desc);

create index if not exists usage_events_user_status_idx
  on public.usage_events (user_id, status);

alter table public.usage_events enable row level security;

drop policy if exists usage_events_select_own on public.usage_events;
create policy usage_events_select_own
on public.usage_events
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists usage_events_insert_own on public.usage_events;
create policy usage_events_insert_own
on public.usage_events
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists usage_events_update_own on public.usage_events;
create policy usage_events_update_own
on public.usage_events
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists usage_events_delete_own on public.usage_events;
create policy usage_events_delete_own
on public.usage_events
for delete
to authenticated
using ((select auth.uid()) = user_id);

create or replace function public._active_usage_count(
  p_user_id uuid,
  p_pending_ttl_minutes integer default 10
)
returns integer
language sql
stable
set search_path = public
as $$
  select count(*)::integer
  from public.usage_events
  where user_id = p_user_id
    and (
      status = 'succeeded'
      or (
        status = 'pending'
        and created_at >= timezone('utc', now()) - make_interval(mins => greatest(p_pending_ttl_minutes, 1))
      )
    );
$$;

create or replace function public.get_usage_snapshot(
  p_pending_ttl_minutes integer default 10
)
returns table (used_count integer)
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  return query
  select public._active_usage_count(v_user_id, p_pending_ttl_minutes);
end;
$$;

create or replace function public.reserve_usage_event(
  p_feature text,
  p_reservation_key text,
  p_limit integer default 3,
  p_pending_ttl_minutes integer default 10
)
returns table (
  allowed boolean,
  used_count integer
)
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_used_count integer;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  perform pg_advisory_xact_lock(hashtextextended(v_user_id::text, 0));

  v_used_count := public._active_usage_count(v_user_id, p_pending_ttl_minutes);

  if exists (
    select 1
    from public.usage_events
    where user_id = v_user_id
      and reservation_key = p_reservation_key
  ) then
    return query select true, v_used_count;
    return;
  end if;

  if v_used_count >= greatest(p_limit, 0) then
    return query select false, v_used_count;
    return;
  end if;

  insert into public.usage_events (
    user_id,
    feature,
    reservation_key,
    status,
    updated_at
  )
  values (
    v_user_id,
    p_feature,
    p_reservation_key,
    'pending',
    timezone('utc', now())
  );

  return query select true, v_used_count + 1;
end;
$$;

create or replace function public.finalize_usage_event(
  p_reservation_key text,
  p_pending_ttl_minutes integer default 10
)
returns table (used_count integer)
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  perform pg_advisory_xact_lock(hashtextextended(v_user_id::text, 0));

  update public.usage_events
  set status = 'succeeded',
      updated_at = timezone('utc', now())
  where user_id = v_user_id
    and reservation_key = p_reservation_key
    and status = 'pending';

  return query
  select public._active_usage_count(v_user_id, p_pending_ttl_minutes);
end;
$$;

create or replace function public.release_usage_event(
  p_reservation_key text,
  p_pending_ttl_minutes integer default 10
)
returns table (used_count integer)
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  perform pg_advisory_xact_lock(hashtextextended(v_user_id::text, 0));

  delete from public.usage_events
  where user_id = v_user_id
    and reservation_key = p_reservation_key
    and status = 'pending';

  return query
  select public._active_usage_count(v_user_id, p_pending_ttl_minutes);
end;
$$;

grant execute on function public.get_usage_snapshot(integer) to authenticated;
grant execute on function public.reserve_usage_event(text, text, integer, integer) to authenticated;
grant execute on function public.finalize_usage_event(text, integer) to authenticated;
grant execute on function public.release_usage_event(text, integer) to authenticated;
