require_relative 'questions_database.rb'
require_relative 'user.rb'
require_relative 'reply.rb'
require_relative 'question.rb'

class QuestionFollower

  def self.followers_for_question_id(question_id)
    results = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_followers JOIN users
      ON
        users.id = question_followers.user_id
      WHERE
        question_followers.question_id = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def self.followed_questions_for_user_id(user_id)
    results = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_followers JOIN questions
      ON
        questions.id = question_followers.question_id
      WHERE
        question_followers.user_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def self.most_followed_questions(n)
    results = QuestionDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions JOIN
        (
          SELECT
            question_followers.question_id, COUNT(*)
          FROM
            question_followers
          GROUP BY
            question_followers.question_id
          ORDER BY
            COUNT(*) DESC
        ) AS followers_count
      ON
        questions.id = followers_count.question_id
      LIMIT
        ?
    SQL

    results.map { |result| Question.new(result) }
  end
end
