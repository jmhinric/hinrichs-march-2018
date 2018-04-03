# == Schema Information
#
# Table name: leagues
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class League < ActiveRecord::Base
  has_many :people, -> { distinct }
  has_and_belongs_to_many :events
  validates_uniqueness_of :name
end
