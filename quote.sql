CREATE DATABASE quote_app;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username varchar(200),
  email varchar(300) not null,
  password_digest TEXT
);

CREATE TABLE quotes (
  id serial primary key,
  user_id integer not null,
  category varchar(200),
  author varchar(200),
  content TEXT,
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT
);


CREATE TABLE favourites (
  id SERIAL PRIMARY KEY,
  quote_id integer NOT NULL,
  user_id integer NOT NULL,
  FOREIGN KEY (quote_id) REFERENCES quotes (id) ON DELETE RESTRICT,
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT
);

-- CREATE TABLE shares (
--   id serial primary key,
--   from_user_id varchar(200),
--   to_user_id varchar(200),
--   quote_id integer NOT NULL,
--   FOREIGN KEY (quote_id) REFERENCES quotes (id) ON DELETE RESTRICT
-- );

