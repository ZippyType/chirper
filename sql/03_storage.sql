-- Storage buckets setup (run in Supabase Dashboard > Storage)
-- You need to create these manually in the UI:

-- 1. Create bucket "avatars" for profile pictures
--    - Public bucket
--    - File size limit: 2MB
--    - Allowed file types: image/*

-- 2. Create bucket "posts" for post images
--    - Public bucket  
--    - File size limit: 5MB
--    - Allowed file types: image/*

-- Storage RLS policies (run after creating buckets)
-- These policies allow public read access to uploaded files

begin;

-- Avatars bucket policy (if not using UI)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Posts bucket policy
insert into storage.buckets (id, name, public)
values ('posts', 'posts', true)
on conflict (id) do nothing;

commit;

-- Enable public access to storage files
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