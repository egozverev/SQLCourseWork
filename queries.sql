set search_path TO coursework, public;
/*Первый запрос - самый простенький, дальше лучше */
/* Продуктивные авторы - те, кто написал больше одной статьи */
with person_and_aricles as(
  select t1.person_id , person_nm, t2.article_id
  from person as t1
  left join article_x_author t2 on
  t1.person_id = t2.person_id
)
select person_nm, count(article_id) as "Number of written articles"
from person_and_aricles
group by person_nm
having count(article_id) > 1;

/* Статья, в написании которой принимало участие больше всего человек и её авторы*/
with extended_article as(
  select t1.article_id, t1.article_nm, t2.person_id
  from article as t1
  left join article_x_author as t2
  on t1.article_id = t2.article_id
), awesome_article as(
  select article_nm, article_id
  from extended_article
  group by article_id, article_nm
  having count(person_id) = (
  select max(cnt) from
    (select count(person_id) as cnt
      from extended_article
      group by article_id, article_nm) as counts
    )
) select t3.person_nm as "The authors", t4.article_nm as "Article name"
from
  (person t1
left join article_x_author t2
on t1.person_id = t2.person_id) as t3
right join awesome_article t4
on t4.article_id = t3.article_id;

/* Лица моложе 21 года, уже принимающие активное участие в написании статей / рецензировании ( Гении ?? ) */
with youth as(
  select * from person where person_age_num < 21
), young_authors as(
  select t1.person_id
  from youth t1
  right join article_x_author t2
  on t1.person_id = t2.person_id
), young_reviewers as(
  select t1.person_id
  from youth t1
  right  join reviewer_x_magazine t2
  on t1.person_id = t2.person_id
), ids_and_flags as(
  select only_authors.person_id, true as "Author", false as "Reviewer"
from(
  select * from young_authors
  except
  select * from young_reviewers) as only_authors

  union

  select only_reviewers.person_id, false as "Author", true as "Reviewer"
from(
  select * from young_reviewers
  except
  select * from young_authors) as only_reviewers

  union

  select freaking_genius.person_id, true as "Author", true as "Reviewer"
  from (
    select * from young_reviewers
    intersect
    select * from young_authors
    ) as freaking_genius
)
select t1.person_nm, t1.person_age_num, t2."Author", t2."Reviewer"
from youth t1
inner join
ids_and_flags t2
on t1.person_id = t2.person_id;

/*Вырезка из рейтинговой таблицы институтов - отображены те, где параметр
efficiency = отношение кол-ва статей к количеству работников максимален и минимальный ( т.е. вершина и низ рейтинга )*/
with institute_workers as(
  select t1.institute_id, t2.person_id
  from institute t1
  left join author_person t2
  on t1.institute_id = t2.institute_id
), institute_articles as (
  select t1.institute_id, t1.person_id, t2.article_id
  from institute_workers t1
  left join article_x_author t2
  on t1.person_id = t2.person_id
), institute_efficency as(
  select institute_id, cast(cnt_articles as numeric)/cnt_people as efficiency
  from(
  select institute_id, count(person_id) as cnt_people, count(article_id) as cnt_articles
  from institute_articles
  group by institute_id
  ) as count_values
)
select * from (
                select *, 'One of the most effective universities' as Label
                from institute_efficency
                where efficiency = (
                  select max(efficiency)
                  from institute_efficency)

                union

                select *, 'One of the most non-effective universities ' as Label
                from institute_efficency
                where efficiency = (
                  select min(efficiency)
                  from institute_efficency)
              ) as ranking_table
order by efficiency desc, institute_id asc;


/* Анализ сферы, в которой было издано больше всего статей - количество статей,
дата первой и последней публикаций, многообразие учёных, принимавших участие в написании статьи,
выраженное в кол-во учёные на кол-во статей,
среднее количество страниц на статью, среднее количество рецензий на статью.
 */
 with fields as(
  select article_subject_txt, count(article_id) as cnt_articles
  from article
   group by article_subject_txt
 ), popular_field as(
   select * from fields t1
   where cnt_articles = (
     select max(cnt_articles) from fields t2
     )
 ), scientists as(
   select t1.article_subject_txt, count(t2.person_id) as cnt_people
   from article t1
   right join article_x_author t2
     on t1.article_id = t2.article_id
   where t1.article_subject_txt in (select article_subject_txt from popular_field)
   group by t1.article_subject_txt
 ), reviewings as (
   select t1.article_subject_txt, count(t2.person_id) as cnt_reviewings
   from article t1
   right join article_x_reviewer t2
     on t1.article_id = t2.article_id
   where t1.article_subject_txt in (select article_subject_txt from popular_field)
   group by t1.article_subject_txt
 ), sub_query as (
   select t1.article_subject_txt, count(t1.article_id) as num_of_articles, min(t1.article_date_of_publication_dt) as first_date,
       max(t1.article_date_of_publication_dt) as last_date, cast(avg(t1.article_number_of_pages_num) as numeric) as avgPgs
from article t1
 where t1.article_subject_txt in (select article_subject_txt from popular_field)
group by t1.article_subject_txt
 )
 select article_subject_txt as Subject,  num_of_articles as "Number of articles", first_date as "First publication date",
        last_date as "Last publication date", cast(cnt_people as numeric)/num_of_articles as "Diversity of scientists coeff",
        cast(cnt_reviewings as numeric)/num_of_articles as "Peer reviewability coeff" /* последнее - рецензируемость*/
from
( select t1.*, t2.cnt_people, t3.cnt_reviewings from
 sub_query t1
inner join scientists t2
on t1.article_subject_txt = t2.article_subject_txt
inner join reviewings t3
on t1.article_subject_txt = t3.article_subject_txt) as t



