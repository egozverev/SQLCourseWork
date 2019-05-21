set search_path TO coursework, public;
drop view if exists show_authors;
drop view if exists get_recent_articles;
drop view if exists get_well_known_institutes_ids;
drop view if exists show_magazines_phones;

create or replace view show_authors as(
  select t1.person_id,
         t1.person_nm,
         case
            when t1.person_age_num >= 18 then 'Adult'
            when t1.person_age_num is null then null
         else 'Child'
         end as maturity,
         substring(t1.person_phone_no, 1, 3) || '*****' || substring(t1.person_phone_no, 9) as phone_num,
         substring(t1.person_email_txt, 1, 3) || '***' || substring(t1.person_email_txt, 7) as email
  from person t1
  where t1.person_author_flg
);
create or replace view get_recent_articles as(
  select *
  from article
  where article_date_of_publication_dt >= now() - interval '1 year'
  );
/* Институты, которые имеют и почту, и телефон, и мыло */
create or replace view get_well_known_institutes_ids as(
  select t1.institute_id as "Number of the institute in the list",
         t1.institute_phone_no as Phone,
         t1.institute_email_txt as Email,
         t1.institute_site_url as Site
  from institute t1
  where institute_phone_no is not null and institute_email_txt is not null and institute_site_url is not null
  );
create or replace view show_magazines_phones as(
  select t1.magazine_nm,
         case when t1.magazine_phone_no is distinct from null then t1.magazine_phone_no
           when t1.magazine_owner_nm is null then 'Suspicious! This magazine doesn`t have a phone and also the owner`s name is unknows. '
          else 'Mister po imeni ' || t1.magazine_owner_nm || 'can`t start using phone for his business in 21st centure. Applause'
        end as phone
  from magazine t1
);
select * from show_authors;
select * from get_recent_articles;
select * from get_well_known_institutes_ids;
select * from show_magazines_phones;



/* "Сложные представления" ( с join ) */

/* Вывести по каждому человеку его активность в последние несколько лет -
 складывается из количества написанных статей и
количества опубликованных статей, подвергшихся обзору данного человека,
отсортировать людей по данном показателю, присвоить каждому человеку ранг.
 */
 drop view if exists activists;
create or replace view activists as(
  with recent_articles as(
    select article_id
    from article
    where article_date_of_publication_dt >= now() - interval '7 years'
    ),
    authors_articles as(
    select t1.person_id, count(t1.article_id) as cnt_articles
    from article_x_author t1
    where t1.article_id in (select * from recent_articles)
    group by t1.person_id
    ),
    reviewers_articles as(
      select t1.person_id, count(t1.article_id) as cnt_reviewings
      from article_x_reviewer t1
      where t1.article_id in (select * from recent_articles)
      group by t1.person_id
    ),
    active_people as(
      select t1.person_id,
             t1.person_nm,
             case when t2.cnt_articles is not null then t2.cnt_articles
               else 0
              end as cnt_articles,
             case when t3.cnt_reviewings is not null then t3.cnt_reviewings
              else 0
              end as cnt_reviewings
      from person t1
      left join authors_articles t2
      on t1.person_id = t2.person_id
      left join reviewers_articles t3
      on t1.person_id = t3.person_id
      )
    select person_nm, cnt_reviewings + cnt_articles as num_of_articles,
           dense_rank() over (order by cnt_reviewings + cnt_articles desc) as rank
    from active_people t1
  where cnt_articles + cnt_reviewings > 0

);

/* Вывести имя человека с самыми "горячими" статьями - т.е. наиболее часто рецензируемыми */
drop view if exists hot_articles_author;
create or replace view hot_articles_author as(
  with article_number_of_reviews as(
    select t1.article_id, count(t2.person_id) as cnt_reviews
    from article t1
    left join
    article_x_reviewer t2
    on t1.article_id = t2.article_id
    group by t1.article_id, t1.article_nm
    ),
    all_authors as(
      select t1.person_id, t1.article_id, t2.cnt_reviews
      from article_x_author t1
      left join article_number_of_reviews t2
      on t1.article_id = t2.article_id
      ),
    author_reviews as(
      select t.person_id, sum(t.cnt_reviews) as measure_of_hot
      from all_authors t
      group by t.person_id
      )
    select t1.person_nm as "Hot Authors"
    from author_reviews t2
    inner join person t1
    on t1.person_id = t2.person_id
    where measure_of_hot = (select max(measure_of_hot) from author_reviews)


);


select * from activists;
select * from hot_articles_author;
