DROP SCHEMA IF EXISTS coursework CASCADE;
CREATE SCHEMA coursework;
set search_path TO coursework, public;

drop table if exists article_x_author cascade ;
drop table if exists article_x_magazine cascade ;
drop table if exists reviewer_x_magazine cascade ;
drop table if exists article_x_reviewer cascade ;
drop table if exists author_person cascade ;
drop table if exists person cascade ;
drop table if exists article cascade ;
drop table if exists institute cascade ;
drop table if exists magazine cascade ;

create table person(
  person_id INT PRIMARY KEY,
  person_nm VARCHAR(50) NOT NULL,
  person_age_num INT CHECK ( person_age_num >=0 ),
  person_phone_no VARCHAR(20) CHECK(person_phone_no ~ '([-():=+]?\d[-():=+]?){10}'),
  person_email_txt VARCHAR(50) UNIQUE ,
  person_reviewer_flg boolean,
  person_author_flg boolean
);
/* regex отбирает номера по типу '+7-914-733-5523'*/

create table article(
  article_id INT PRIMARY KEY ,
  article_nm VARCHAR(50) NOT NULL,
  article_subject_txt VARCHAR(50) NOT NULL ,
  article_number_of_pages_num INT CHECK ( article_number_of_pages_num >= 0 ),
  article_date_of_publication_dt date NOT NULL
);

create table magazine(
  magazine_id INT PRIMARY KEY ,
  magazine_nm VARCHAR(50) NOT NULL,
  magazine_address_txt VARCHAR(100)  ,
  magazine_site_url VARCHAR(50) UNIQUE,
  magazine_email_txt VARCHAR(50),
  magazine_phone_no VARCHAR(20) CHECK ( magazine_phone_no ~ '([-():=+]?\d[-():=+]?){10}'),
  magazine_owner_nm VARCHAR(50)
);

create table institute(
  institute_id INT PRIMARY KEY ,
  institute_address_txt VARCHAR(100)  ,
  institute_site_url VARCHAR(50) UNIQUE,
  institute_email_txt VARCHAR(50),
  institute_phone_no VARCHAR(20) CHECK ( institute_phone_no ~ '([-():=+]?\d[-():=+]?){10}')
);

create table author_person(
  person_id INT REFERENCES person(person_id),
  institute_id INT  REFERENCES institute(institute_id)
);
create table article_x_author(
  person_id INT REFERENCES person(person_id),
  article_id INT REFERENCES article(article_id)
);
create table article_x_magazine(
  article_id INT references article(article_id),
  magazine_id INT REFERENCES magazine(magazine_id)
);
create table article_x_reviewer(
  article_id INT references article(article_id),
  person_id INT REFERENCES person(person_id)
);
create table reviewer_x_magazine(
  person_id INT REFERENCES person(person_id),
  magazine_id INT REFERENCES magazine(magazine_id)
);
