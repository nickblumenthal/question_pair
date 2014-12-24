require_relative 'questions_database.rb'
require_relative 'user.rb'
require_relative 'reply.rb'
require_relative 'question_follower.rb'
require_relative 'question_like.rb'
require_relative 'saving.rb'

class Question
  include Saving
  attr_accessor :id, :title, :body, :author_id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def self.find_by_id(id)
    results = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = ?
    SQL

    results.map { |result| Question.new(result) }.first
  end

  def self.find_by_author_id(author_id)
    results = QuestionDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.author_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def self.most_followed(n)
    QuestionFollower.most_followed_questions(n)
  end

  def author
    results = QuestionDatabase.instance.execute(<<-SQL)
      SELECT
        users.*
      FROM
        users INNER JOIN questions
      ON
        users.id = questions.author_id
    SQL

    results.map { |result| User.new(result) }.first
  end

  def replies
    results = QuestionDatabase.instance.execute(<<-SQL)
      SELECT
        replies.*
      FROM
        replies INNER JOIN questions
      ON
        questions.id = replies.question_id
    SQL

    results.map { |result| Reply.new(result) }.first
  end

  def followers
    QuestionFollower.followers_for_question_id(self.id)
  end

  def likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end

  def most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
end
