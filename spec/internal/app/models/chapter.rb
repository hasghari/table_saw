# frozen_string_literal: true

class Chapter < ActiveRecord::Base
  belongs_to :book
end
