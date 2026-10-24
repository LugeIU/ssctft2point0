-- Hosts can now save results and correct games that are not settled yet.
-- They still cannot touch players, deposits, withdrawals or settlements.
drop policy if exists "host update lobby" on games;
drop policy if exists "host update games" on games;
create policy "host update games" on games for update to authenticated
  using (app_role() = 'host' and settled = false)
  with check (app_role() = 'host' and settled = false);
