-- Chirper App - Complete Database Schema
-- Run this entire script in Supabase SQL Editor

-- Enable UUID extension
create extension if not exists "pgcrypto";

-- ============================================
-- 1. PROFILES TABLE
-- ============================================
create table public.profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamp with time zone,
  username text unique not null,
  full_name text,
  avatar_url text,
  bio text,
  website text,
  created_at timestamptz default now()
);

-- ============================================
-- 2. POSTS TABLE
-- ============================================
create table public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  content text not null,
  image_url text,
  likes_count int default 0,
  comments_count int default 0,
  created_at timestamptz default now()
);

-- ============================================
-- 3. LIKES TABLE
-- ============================================
create table public.likes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  post_id uuid references posts(id) not null,
  created_at timestamptz default now(),
  unique(user_id, post_id)
);

-- ============================================
-- 4. COMMENTS TABLE
-- ============================================
create table public.comments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  post_id uuid references posts(id) not null,
  content text not null,
  created_at timestamptz default now()
);

-- ============================================
-- 5. FOLLOWS TABLE
-- ============================================
create table public.follows (
  id uuid primary key default gen_random_uuid(),
  follower_id uuid references profiles(id) not null,
  following_id uuid references profiles(id) not null,
  created_at timestamptz default now(),
  unique(follower_id, following_id)
);

-- ============================================
-- 6. NOTIFICATIONS TABLE
-- ============================================
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  sender_id uuid references profiles(id) not null,
  type text not null,
  post_id uuid references posts(id),
  read boolean default false,
  created_at timestamptz default now()
);

-- ============================================
-- INDEXES
-- ============================================
create index idx_posts_user_id on posts(user_id);
create index idx_posts_created on posts(created_at desc);
create index idx_likes_post on likes(post_id);
create index idx_comments_post on comments(post_id);
create index idx_follows_follower on follows(follower_id);
create index idx_follows_following on follows(following_id);
create index idx_notifications_user on notifications(user_id, read);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================
alter table profiles enable row level security;
alter table posts enable row level security;
alter table likes enable row level security;
alter table comments enable row level security;
alter table follows enable row level security;
alter table notifications enable row level security;

-- PROFILES policies
create policy "Public profiles are viewable by everyone" on profiles for select using (true);
create policy "Users can insert their own profile" on profiles for insert with check ((select auth.uid()) = id);
create policy "Users can update own profile" on profiles for update using ((select auth.uid()) = id);

-- POSTS policies
create policy "Anyone can view posts" on posts for select using (true);
create policy "Authenticated users can create posts" on posts for insert with check ((select auth.uid()) = user_id);
create policy "Users can update own posts" on posts for update using ((select auth.uid()) = user_id);
create policy "Users can delete own posts" on posts for delete using ((select auth.uid()) = user_id);

-- LIKES policies
create policy "Anyone can view likes" on likes for select using (true);
create policy "Users can like posts" on likes for insert with check ((select auth.uid()) = user_id);
create policy "Users can unlike posts" on likes for delete using ((select auth.uid()) = user_id);

-- COMMENTS policies
create policy "Anyone can view comments" on comments for select using (true);
create policy "Users can comment" on comments for insert with check ((select auth.uid()) = user_id);

-- FOLLOWS policies
create policy "Anyone can view follows" on follows for select using (true);
create policy "Users can follow" on follows for insert with check ((select auth.uid()) = follower_id);
create policy "Users can unfollow" on follows for delete using ((select auth.uid()) = follower_id);

-- NOTIFICATIONS policies
create policy "Users can view own notifications" on notifications for select using ((select auth.uid()) = user_id);

-- ============================================
-- AUTO-CREATE PROFILE TRIGGER
-- ============================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, full_name)
  values (new.id, new.raw_user_meta_data->>'username', new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================
-- AUTO-UPDATE POST COUNTS (LIKES)
-- ============================================
create or replace function public.update_post_likes_count()
returns trigger as $$
begin
  if tg_op = 'INSERT' then
    update public.posts 
    set likes_count = likes_count + 1 
    where id = new.post_id;
  elsif tg_op = 'DELETE' then
    update public.posts 
    set likes_count = greatest(likes_count - 1, 0) 
    where id = old.post_id;
  end if;
  return null;
end;
$$ language plpgsql security definer;

create trigger on_like_inserted
  after insert on public.likes
  for each row execute procedure public.update_post_likes_count();

create trigger on_like_deleted
  after delete on public.likes
  for each row execute procedure public.update_post_likes_count();

-- ============================================
-- AUTO-UPDATE POST COUNTS (COMMENTS)
-- ============================================
create or replace function public.update_post_comments_count()
returns trigger as $$
begin
  if tg_op = 'INSERT' then
    update public.posts 
    set comments_count = comments_count + 1 
    where id = new.post_id;
  elsif tg_op = 'DELETE' then
    update public.posts 
    set comments_count = greatest(comments_count - 1, 0) 
    where id = old.post_id;
  end if;
  return null;
end;
$$ language plpgsql security definer;

create trigger on_comment_inserted
  after insert on public.comments
  for each row execute procedure public.update_post_comments_count();

create trigger on_comment_deleted
  after delete on public.comments
  for each row execute procedure public.update_post_comments_count();

-- ============================================
-- STORAGE BUCKETS
-- ============================================
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('posts', 'posts', true)
on conflict (id) do nothing;

-- Storage RLS policies
create policy "Avatar images are publicly accessible" on storage.objects
for select using (bucket_id = 'avatars');

create policy "Anyone can upload avatar" on storage.objects
for insert with check (bucket_id = 'avatars');

create policy "Anyone can update own avatar" on storage.objects
for update using (bucket_id = 'avatars');

create policy "Post images are publicly accessible" on storage.objects
for select using (bucket_id = 'posts');

create policy "Authenticated users can upload posts" on storage.objects
for insert with check (bucket_id = 'posts');