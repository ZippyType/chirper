-- Row Level Security (RLS) Policies

-- Enable RLS on all tables
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