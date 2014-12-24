DROP TABLE users;
DROP TABLE questions;
DROP TABLE question_followers;
DROP TABLE replies;
DROP TABLE question_likes;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_followers (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  PRIMARY KEY (question_id, user_id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  PRIMARY KEY (question_id, user_id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('John', 'Smith'), ('Jane', 'Smith'), ('Bob', 'Smith');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Best programming language?', 'What is the best programming language to learn?'
    , (SELECT id FROM users WHERE fname = 'John' AND lname = 'Smith')),
  ('Best holiday?', 'What is the best holiday?'
    , (SELECT id FROM users WHERE fname = 'John' AND lname = 'Smith')),
  ('Best color?', 'What is the best color?'
    , (SELECT id FROM users WHERE fname = 'John' AND lname = 'Smith'));

INSERT INTO
  replies (question_id, parent_reply_id, user_id, body)
VALUES
  (1, NULL, 2, 'JavaScript'),
  (1, 1, 3, 'C++');

INSERT INTO
  question_followers (question_id, user_id)
VALUES
  (1, 1), (1, 3), (2, 2);

INSERT INTO
  question_likes (question_id, user_id)
VALUES
  (1, 3), (2, 3);
