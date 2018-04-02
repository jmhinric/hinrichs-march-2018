# == Schema Information
#
# Table name: people
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  starting_weight :decimal(, )
#  up_by           :decimal(, )
#  league_id       :integer
#

class Person < ActiveRecord::Base

  belongs_to :league
  has_many :checkins
  has_many :user_person_joins
  # How can a person have many users?  I'm not sure what this is going towards.
  has_many :users, through: :user_person_joins
  # TODO: the User and Person models need to be clarified.
  #   'name' should be an attribute of User, and this model should have a user_id.
  #   This model could also maybe be renamed to something like 'Participation.'
  validates_uniqueness_of :name

  def up_by(event=nil)
    return attributes['up_by'] unless event
    checkins_from_event = event.checkins.where(person: self).order(:created_at)
    first_checkin = checkins_from_event.first
    last_checkin = checkins_from_event.last
    last_checkin == first_checkin ? nil : last_checkin.weight - first_checkin.weight
  end

  def percentage_change
    return unless starting_weight && up_by
    @percentage_change ||= up_by.to_f / starting_weight * 100
  end

  def checkin_diffs
    grouped = checkins.includes(:event).order('events.created_at').group_by(&:event)
    event_diffs = {}
    grouped.each_pair do |event, event_checkins|
      diffs = event_checkins.sort_by(&:created_at).map(&:delta).compact
      event_diffs[event.try(:name)] = diffs.map { |d| '%.2f' % d }
    end
    event_diffs
  end
end
