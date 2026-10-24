-- 1. lobby name (lets several lobbies run at once)
alter table games add column if not exists name text;

-- 2. read the role from the login token
create or replace function public.app_role() returns text
language sql stable as $$ select auth.jwt() -> 'app_metadata' ->> 'role' $$;

-- 3. replace the old "any logged-in user can write" policies
drop policy if exists "admin players" on players;
drop policy if exists "admin games" on games;
drop policy if exists "admin settlements" on settlements;

-- admin: can change everything
create policy "admin players" on players for all to authenticated using (app_role() = 'admin') with check (app_role() = 'admin');
create policy "admin games" on games for all to authenticated using (app_role() = 'admin') with check (app_role() = 'admin');
create policy "admin settlements" on settlements for all to authenticated using (app_role() = 'admin') with check (app_role() = 'admin');

-- host: can only create, update and delete lobbies that are not finished, and can never write results or touch players
create policy "host insert lobby" on games for insert to authenticated
  with check (app_role() = 'host' and done = false and deltas is null);
create policy "host update lobby" on games for update to authenticated
  using (app_role() = 'host' and done = false)
  with check (app_role() = 'host' and done = false and deltas is null);
create policy "host delete lobby" on games for delete to authenticated
  using (app_role() = 'host' and done = false);

-- 4. give each account its role: EDIT ADMIN_EMAIL_HERE before running
update auth.users set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}' where email = 'ngtr29@gmail.com';
update auth.users set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"host"}'
where lower(email) in ('inusaki@gmail.com', 'sol1@gmail.com', 'tkn@gmail.com', 'missyukc@gmail.com');
