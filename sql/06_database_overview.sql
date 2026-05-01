-- ============================================
-- Chirper Database Overview Script
-- Run this in Supabase Dashboard > SQL Editor
-- ============================================

-- 1. LIST ALL TABLES
SELECT 'Tables' as category, table_name as name
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2. LIST ALL BUCKETS  
SELECT 'Buckets' as category, id as bucket_name, public as is_public
FROM storage.buckets
ORDER BY id;

-- 3. COUNT RECORDS IN EACH TABLE
SELECT 'Total Records' as info, 'profiles' as table_name, count(*) FROM profiles
UNION ALL SELECT '', 'posts', count(*) FROM posts
UNION ALL SELECT '', 'comments', count(*) FROM comments
UNION ALL SELECT '', 'likes', count(*) FROM likes
UNION ALL SELECT '', 'follows', count(*) FROM follows;

-- 4. STORAGE FILES COUNT BY BUCKET
SELECT 'Storage' as info, bucket_id, count(*) as files
FROM storage.objects
GROUP BY bucket_id;

-- 5. RECENT POSTS (last 10)
SELECT 'Recent Posts' as info, left(p.content, 50) as content, u.username, p.created_at
FROM posts p
LEFT JOIN profiles u ON p.user_id = u.id
ORDER BY p.created_at DESC
LIMIT 10;

-- 6. TOP FOLLOWED USERS
SELECT 'Top Followed' as info, p.username, count(f.follower_id) as followers
FROM profiles p
JOIN follows f ON f.following_id = p.id
GROUP BY p.username
ORDER BY followers DESC
LIMIT 10;

-- 7. ROW LEVEL SECURITY POLICIES
SELECT 'RLS Policies' as info, tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename;

-- 8. STORAGE BUCKET DETAILS
SELECT 'Bucket Config' as info, 
    id, 
    public, 
    file_size_limit as size_limit, 
    allowed_mime_types as allowed_types,
    Array_length(allowed_mime_types, 1) as type_count
FROM storage.buckets;

-- 9. CREATE BUCKETS (run if buckets don't exist)
-- Uncomment to run:
-- INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('posts', 'posts', true);

-- 10. STORAGE POLICIES (for public read access)
-- Avatars bucket:
-- create policy "avatars_public_read" on storage.objects for select using (bucket_id = 'avatars');
-- create policy "avatars_auth_upload" on storage.objects for insert with check (bucket_id = 'avatars');

-- Posts bucket:
-- create policy "posts_public_read" on storage.objects for select using (bucket_id = 'posts');
-- create policy "posts_auth_upload" on storage.objects for insert with check (bucket_id = 'posts');