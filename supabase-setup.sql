-- 我的工作台：Supabase 云同步建表脚本
-- 使用方法：
-- 1. 登录 Supabase，进入你的项目
-- 2. 打开 SQL Editor
-- 3. 粘贴并运行本文件全部内容
-- 4. 在 Table Editor 里确认存在 public.workspace_data 表
-- 5. 在 Database > Replication 里把 workspace_data 加入 Realtime 发布

create table if not exists public.workspace_data (
  workspace_id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.workspace_data enable row level security;

drop policy if exists "workspace_data_select_for_anon" on public.workspace_data;
drop policy if exists "workspace_data_insert_for_anon" on public.workspace_data;
drop policy if exists "workspace_data_update_for_anon" on public.workspace_data;
drop policy if exists "workspace_data_delete_for_anon" on public.workspace_data;

create policy "workspace_data_select_for_anon"
on public.workspace_data
for select
to anon
using (true);

create policy "workspace_data_insert_for_anon"
on public.workspace_data
for insert
to anon
with check (true);

create policy "workspace_data_update_for_anon"
on public.workspace_data
for update
to anon
using (true)
with check (true);

create policy "workspace_data_delete_for_anon"
on public.workspace_data
for delete
to anon
using (true);

create or replace function public.set_workspace_data_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_workspace_data_updated_at on public.workspace_data;

create trigger set_workspace_data_updated_at
before update on public.workspace_data
for each row
execute function public.set_workspace_data_updated_at();
