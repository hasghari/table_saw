# frozen_string_literal: true

class Book < ActiveRecord::Base
  belongs_to :author
end
