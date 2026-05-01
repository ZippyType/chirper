-- Auto-create profile when user signs up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, full_name)
  values (new.id, new.raw_user_meta_data->>'username', new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to create profile on new user signup
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Function to update post counts (likes/comments)
create or replace function public.update_post_counts()
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

-- Trigger for likes count
create trigger on_like_inserted
  after insert on public.likes
  for each row execute procedure public.update_post_counts();

create trigger on_like_deleted
  after delete on public.likes
  for each row execute procedure public.update_post_counts();

-- Function for comments count
create or replace function public.update_comments_count()
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
  for each row execute procedure public.update_comments_count();

create trigger on_comment_deleted
  after delete on public.comments
  for each row execute procedure public.update_comments_count();