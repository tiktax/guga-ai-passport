-- =====================================================
-- 生成AIパスポート学習ガイド Supabase セットアップSQL
-- Supabase Dashboard > SQL Editor に貼り付けて実行
-- =====================================================

-- ユーザープロフィールテーブル
create table public.user_profiles (
  user_id   uuid references auth.users(id) on delete cascade primary key,
  display_name text not null default '',
  level        text not null default 'beginner',  -- beginner / intermediate / advanced
  known_tasks  jsonb not null default '[]',        -- ["t1","t3",...] 既知タスクID配列
  target_date  date,                               -- 試験目標日
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- Row Level Security (自分のデータのみ操作可)
alter table public.user_profiles enable row level security;

create policy "own profile" on public.user_profiles
  for all using (auth.uid() = user_id);

-- 模擬試験スコアテーブル
create table public.quiz_scores (
  id          uuid default gen_random_uuid() primary key,
  user_id     uuid references auth.users(id) on delete cascade,
  created_at  timestamptz default now(),
  total       integer not null,
  pct         integer not null,
  by_chapter  jsonb not null default '{}'
  -- by_chapter 例: {"第1章":{"correct":3,"total":4,"pct":75}, ...}
);

alter table public.quiz_scores enable row level security;

create policy "own scores" on public.quiz_scores
  for all using (auth.uid() = user_id);

-- インデックス (履歴取得を高速化)
create index quiz_scores_user_date on public.quiz_scores(user_id, created_at desc);

-- =====================================================
-- 確認クエリ（セットアップ後に実行して確認）
-- =====================================================
-- select * from public.user_profiles;
-- select * from public.quiz_scores;
