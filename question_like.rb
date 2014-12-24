require_relative 'questions_database.rb'
require_relative 'user.rb'
require_relative 'reply.rb'

class QuestionLike

  def self.likers_for_question_id(question_id)
    results = QuestionDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.*
    FROM
      question_likes JOIN users
    ON
      users.id = question_likes.user_id
    WHERE
      question_likes.question_id = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def self.liked_questions_for_user_id(user_id)
    results = QuestionDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM
      question_likes JOIN questions
    ON
      questions.id = question_likes.question_id
    WHERE
      question_likes.user_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def self.num_likes_for_question_id(question_id)
    results = QuestionDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(*)
    FROM
      question_likes
    WHERE
      question_likes.question_id = ?
    GROUP BY
      question_likes.question_id
    SQL

    results[0].values.last
  end

  def self.most_liked_questions(n)
    results = QuestionDatabase.instance.execute(<<-SQL, n)
    SELECT
      questions.*
    FROM
      questions JOIN
    (
      SELECT
        question_likes.question_id, COUNT(*)
      FROM
        question_likes
      GROUP BY
        question_likes.question_id
      ORDER BY
        COUNT(*) DESC
    ) AS likes_count
    ON
      questions.id = likes_count.question_id
    LIMIT
      ?
    SQL
    
    results.map { |result| Question.new(result) }
  end
end
