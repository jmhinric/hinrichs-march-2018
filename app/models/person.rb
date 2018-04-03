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
#  event_id        :integer
#

# TODO: possibly rename this model to 'Participant' or 'Participation'-
#   it's a user's participation in an event with a league
class Person < ActiveRecord::Base

  belongs_to :league
  belongs_to :event
  has_many :checkins
  has_many :user_person_joins
  # How can a person have many users?  I'm not sure what this is going towards
  has_many :users, through: :user_person_joins
  # TODO: the User and Person models need to be clarified- `name` belongs on User
  validate :uniqueness_of_name_per_event

  def up_by(event=nil)
    return attributes['up_by'] unless event
    checkins_from_event = event.checkins.where(person: self).order(:created_at)
    first_checkin = checkins_from_event.first
    last_checkin = checkins_from_event.last
    last_checkin == first_checkin ? nil : last_checkin.weight - first_checkin.weight
  end

  # Another option is that the `starting_weight` attribute is eliminated from this model-
  #   it could just be the weight from the first Checkin of the Person (Participation).
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

  private

  def uniqueness_of_name_per_event
    return unless name && event
    if (event.people.where.not(id: id)).map(&:name).include?(name)
      logger.error('Person name uniqueness violation')
      errors.add(:name, 'must be unique within an event')
    end
  end
end
