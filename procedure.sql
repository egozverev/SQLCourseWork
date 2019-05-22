set search_path TO coursework, public;

create or replace function get_avg_of_number_of_pages_by_sum_pages_num(people_num numeric, pages_num numeric) returns numeric as $$
  begin
    return pages_num/people_num;
  end;
  $$ language plpgsql;





create or replace function get_avg_num_of_pages() returns numeric as $$
  with authors as(
    select distinct person_id
    from article_x_author
  ), authors_number as(
    select count(person_id) as cnt
    from authors
  ), article_number as(
    select sum(article_number_of_pages_num) as cnt
    from article
  ) select * from get_avg_of_number_of_pages_by_sum_pages_num(cast((select cnt from authors_number) as numeric), (select cnt from article_number));
  $$ language sql;
select * from get_avg_of_number_of_pages();
