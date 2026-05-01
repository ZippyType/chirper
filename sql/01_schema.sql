-- Enable UUID extension
create extension if not exists "pgcrypto";

-- 1. PROFILES table (extends auth.users)
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

-- 2. POSTS table
create table public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  content text not null,
  image_url text,
  likes_count int default 0,
  comments_count int default 0,
  created_at timestamptz default now()
);

-- 3. LIKES table
create table public.likes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  post_id uuid references posts(id) not null,
  created_at timestamptz default now(),
  unique(user_id, post_id)
);

-- 4. COMMENTS table
create table public.comments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  post_id uuid references posts(id) not null,
  content text not null,
  created_at timestamptz default now()
);

-- 5. FOLLOWS table
create table public.follows (
  id uuid primary key default gen_random_uuid(),
  follower_id uuid references profiles(id) not null,
  following_id uuid references profiles(id) not null,
  created_at timestamptz default now(),
  unique(follower_id, following_id)
);

-- 6. NOTIFICATIONS table
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  sender_id uuid references profiles(id) not null,
  type text not null,
  post_id uuid references posts(id),
  read boolean default false,
  created_at timestamptz default now()
);

-- Indexes for performance
create index idx_posts_user_id on posts(user_id);
create index idx_posts_created on posts(created_at desc);
create index idx_likes_post on likes(post_id);
create index idx_comments_post on comments(post_id);
create index idx_follows_follower on follows(follower_id);
create index idx_follows_following on follows(following_id);
create index idx_notifications_user on notifications(user_id, read);