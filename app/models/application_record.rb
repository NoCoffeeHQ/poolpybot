# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # TO BE ADDED TO THE SaaS Rails template
  def self.[](attribute_name)
    arel_table[attribute_name]
  end

  def self.t
    arel_table
  end
end
