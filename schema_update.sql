alter table games add column settled boolean not null default false;
create table settlements (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  snapshot jsonb not null
);
alter table settlements enable row level security;
create policy "read settlements" on settlements for select using (true);
create policy "admin settlements" on settlements for all to authenticated using (true) with check (true);
