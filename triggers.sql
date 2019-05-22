set search_path TO coursework, public;
create or replace function change_person_to_author() returns trigger as $$
  begin
    update person
    set person_author_flg = true
    where person_id = new.person_id;
    return null;
  end;
  $$ language plpgsql;

create or replace function change_person_to_reviewer() returns trigger as $$
  begin
    update person
    set person_reviewer_flg = true
    where person_id = new.person_id;
    return null;
  end;
  $$ language plpgsql;
drop trigger if exists update_article_author on article_x_author;
drop trigger if exists update_article_reviewer on article_x_reviewer;

create trigger update_article_author
  after insert
  on article_x_author
  for each row execute procedure change_person_to_author();

create trigger update_article_reviewer
  after insert
  on article_x_reviewer
  for each row execute procedure change_person_to_reviewer();

create or replace function correct_date() returns trigger as $$
  begin
    update article
    set article_date_of_publication_dt = now()
    where article_id = new.article_id and new.article_date_of_publication_dt > now();
    return null;
  end;
  $$ language plpgsql;
drop trigger if exists check_date on article;
create trigger check_date
  after insert
  on article
  for each row execute procedure correct_date();

