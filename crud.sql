set search_path TO coursework, public;

insert into article(article_id, article_nm, article_subject_txt, article_number_of_pages_num, article_date_of_publication_dt)
values (10, 'Fails in old theory of Plistalniy Gaze method', 'Math', 34, '2019-05-21');

select * from article
where article_subject_txt = 'Math';

update reviewer_x_magazine
set magazine_id = 2
where person_id = 7 and magazine_id = 1;

delete from person
where not person_author_flg and not person_reviewer_flg;
