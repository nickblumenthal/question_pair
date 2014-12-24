require 'active_support/inflector'

module Saving
  def save
    if self.id.nil?
      create
    else
      update
    end
  end

  def create
    raise 'already saved!' unless self.id.nil?

    # Get instance variable symbols
    inst_var = self.instance_variables.map { |sym| sym.to_s.gsub('@', '').to_sym }
    inst_var.delete(:id)
    inst_var_string = "(#{inst_var.join(', ')})"
    params = inst_var.map { |var| self.send(var) }
    question_mark_string = Saving.create_value_string(inst_var.count)

    QuestionDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        #{self.class.to_s.downcase.pluralize} #{inst_var_string}
      VALUES
        #{question_mark_string}
    SQL
    self.id = QuestionDatabase.instance.last_insert_row_id
  end

  def update
    raise 'Unknown user' if self.id.nil?

    # Get instance variable symbols
    inst_var = self.instance_variables.map { |sym| sym.to_s.gsub('@', '').to_sym }
    inst_var.delete(:id)
    inst_var_string = "#{inst_var.join('= ?, ')} =?"
    params = inst_var.map { |var| self.send(var) }
    params << self.id
    question_mark_string = Saving.create_value_string(inst_var.count)

    QuestionDatabase.instance.execute(<<-SQL, *params)
      UPDATE
        #{self.class.to_s.downcase.pluralize}
      SET
        #{inst_var_string}
      WHERE
        id = ?
    SQL
  end

  def self.create_value_string(count)
    #answer =
    question_arr = Array.new(count, '?')
    #answer <<
    "(" + question_arr.join(', ') + ")"
  end
end
