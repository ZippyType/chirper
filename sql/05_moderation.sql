-- Chirper Moderation System - Database Updates
-- Run this script in Supabase SQL Editor

-- ============================================
-- Add warning/ban columns to profiles
-- ============================================
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS warnings int default 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS banned boolean default false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS ban_date timestamptz;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS strike_reason text;

-- ============================================
-- Add processed flag to posts (to avoid double-moderation)
-- ============================================
ALTER TABLE posts ADD COLUMN IF NOT EXISTS moderated boolean default false;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS moderation_reason text;

-- ============================================
-- Create moderation log table
-- ============================================
CREATE TABLE IF NOT EXISTS public.moderation_log (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references posts(id),
  user_id uuid references profiles(id),
  reason text not null,
  severity text check (severity in ('low', 'medium', 'high', 'critical')),
  created_at timestamptz default now()
);

-- ============================================
-- Index for moderation queries
-- ============================================
CREATE INDEX IF NOT EXISTS idx_moderation_log_date ON moderation_log(created_at desc);
CREATE INDEX IF NOT EXISTS idx_moderation_log_user ON moderation_log(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_moderated ON posts(moderated) where moderated = false;

-- ============================================
-- RLS for moderation_log
-- ============================================
ALTER TABLE moderation_log enable row level security;

-- Anyone can read moderation log (or restrict to admins)
CREATE POLICY "Anyone can view moderation log" ON moderation_log for select using (true);

-- ============================================
-- Moderation results view
-- ============================================
CREATE OR REPLACE VIEW public.moderation_stats AS
SELECT 
  p.id as user_id,
  p.username,
  p.warnings,
  p.banned,
  p.ban_date,
  COUNT(m.id) as total_strikes
FROM profiles p
LEFT JOIN moderation_log m ON p.id = m.user_id
GROUP BY p.id, p.username, p.warnings, p.banned, p.ban_date;

-- ============================================
-- Trigger to auto-ban at 3 warnings
-- ============================================
CREATE OR REPLACE FUNCTION public.auto_ban_user()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.warnings >= 3 AND (OLD.warnings IS NULL OR OLD.warnings < 3) THEN
    NEW.banned := true;
    NEW.ban_date := now();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_ban_threshold ON profiles;

CREATE TRIGGER check_ban_threshold
  AFTER UPDATE ON profiles
  FOR EACH ROW
  EXECUTE PROCEDURE public.auto_ban_user();

-- ============================================
-- Function to add warning
-- ============================================
CREATE OR REPLACE FUNCTION public.add_user_warning(user_uuid uuid, reason text)
RETURNS void AS $$
BEGIN
  UPDATE profiles 
  SET warnings = COALESCE(warnings, 0) + 1,
      strike_reason = reason
  WHERE id = user_uuid;
  
  -- Insert into moderation log
  INSERT INTO moderation_log (user_id, reason, severity)
  VALUES (user_uuid, reason, 'medium');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Function to check if user is banned
-- ============================================
CREATE OR REPLACE FUNCTION public.is_user_banned(user_uuid uuid)
RETURNS boolean AS $$
DECLARE
  is_banned boolean;
BEGIN
  SELECT banned INTO is_banned
  FROM profiles
  WHERE id = user_uuid;
  
  RETURN COALESCE(is_banned, false);
END;
$$ LANGUAGE plpgsql STABLE;

SELECT 'Moderation system tables and functions created successfully!';
SELECT 'Columns added: warnings, banned, ban_date, strike_reason';
SELECT 'Run moderation_log to track violations';