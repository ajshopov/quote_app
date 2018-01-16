CREATE DATABASE quote_app;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username varchar(200),
  email varchar(300) not null,
  password_digest varchar(400)
);

CREATE TABLE quotes (
  id serial primary key,
  content varchar(5000),
  author varchar(200),
  category varchar(200),
  created_at datetime,
  uploaded_by varchar(200)
);

CREATE TABLE shares (
  id serial primary key,
  from_user varchar(200),
  to_user varchar(200),
  quote_id integer NOT NULL,
  FOREIGN KEY (quote_id) REFERENCES quotes (id) ON DELETE RESTRICT
);

