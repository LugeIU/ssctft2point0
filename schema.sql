create table players (
  id bigint generated always as identity primary key,
  name text unique not null,
  deposit numeric not null default 0,
  withdraw numeric not null default 0
);
create table games (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  players jsonb not null,   -- 8 names
  teams jsonb,              -- [[a,b],[c,d],[e,f],[g,h]]
  places jsonb,             -- {name: placement}
  deltas jsonb,             -- {name: money change}
  jar numeric not null default 0,
  done boolean not null default false
);
alter table players enable row level security;
alter table games enable row level security;
-- everyone can read, only the logged-in admin can write
create policy "read players" on players for select using (true);
create policy "admin players" on players for all to authenticated using (true) with check (true);
create policy "read games" on games for select using (true);
create policy "admin games" on games for all to authenticated using (true) with check (true);
