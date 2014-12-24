require_relative 'questions_database.rb'
require_relative 'question.rb'
require_relative 'saving.rb'

class User
  include Saving
  attr_accessor :fname, :lname, :id

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_id(id)
    results = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL

    results.map { |result| User.new(result) }.first
  end

  def self.find_by_name(fname, lname)
    results = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        users.fname = ? AND users.lname = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollower.followed_questions_for_user_id(self.id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end

  def average_karma
    results = QuestionDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        num_questions/CAST(num_likes AS FLOAT) as karma
      FROM (
        SELECT
          COUNT(DISTINCT(id)) num_questions, SUM(likes) num_likes
        FROM (
          SELECT
            questions.id, COUNT(question_likes.question_id) likes
          FROM
            questions LEFT OUTER JOIN question_likes
          ON
            questions.id = question_likes.question_id
          WHERE
            questions.author_id = ?
          GROUP BY
            questions.id
          ) as likes_table
        )
    SQL
    results[0]['karma']
  end

  # def save
  #   if self.id.nil?
  #     create
  #   else
  #     update
  #   end
  # end

  private

  # def create
  #   raise 'already saved!' unless self.id.nil?
  #   params = [self.fname, self.lname]
  #   QuestionDatabase.instance.execute(<<-SQL, *params)
  #     INSERT INTO
  #       users (fname, lname)
  #       VALUES
  #     (?, ?)
  #   SQL
  #   self.id = QuestionDatabase.instance.last_insert_row_id
  # end

  # def update
  #   raise 'Unknown user' if self.id.nil?
  #   params = [self.fname, self.lname, self.id]
  #   QuestionDatabase.instance.execute(<<-SQL, self.fname, self.lname, self.id)
  #     UPDATE
  #       users
  #     SET
  #       fname = ?, lname = ?
  #     WHERE
  #       id = ?
  #   SQL
  # end
end
