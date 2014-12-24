require_relative 'questions_database.rb'
require_relative 'user.rb'
require_relative 'question.rb'
require_relative 'saving.rb'

class Reply
  include Saving
  attr_accessor :id, :question_id, :body, :parent_reply_id, :user_id

  def initialize(options = {})
    @id = options['id']
    @question_id = options['question_id']
    @body = options['body']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
  end

  def self.find_by_id(id)
    results = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
      SQL

    results.map { |result| Reply.new(result) }.first
  end

  def self.find_by_question_id(question_id)
    results = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.question_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def self.find_by_user_id(user_id)
    results = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.user_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def author
    results = QuestionDatabase.instance.execute(<<-SQL, self.user_id)
      SELECT
        users.*
      FROM
        users INNER JOIN replies
      ON
        users.id = ?
      SQL

      results.map { |result| User.new(result) }.first
  end

  def question
    results = QuestionDatabase.instance.execute(<<-SQL, self.question_id)
      SELECT
        questions.*
      FROM
        questions INNER JOIN replies
      ON
        questions.id = ?
      SQL

      results.map { |result| Question.new(result) }.first
  end

  def parent_reply
    results = QuestionDatabase.instance.execute(<<-SQL, self.parent_reply_id)
      SELECT
        replies.*
      FROM
        replies
      WHERE
        id = ?
      SQL

      results.map { |result| Reply.new(result) }.first
  end

  def child_replies
    results = QuestionDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        replies.*
      FROM
        replies
      WHERE
        parent_reply_id = ?
      SQL

      results.map { |result| Reply.new(result) }
  end
end
