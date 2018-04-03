class CreateCheckin

  def self.call(person, event, weight, current_user)
    return if ENV['QUIET_MODE']

    previous_checkin = Checkin.where(person: person, event: event).first
    delta = nil
    delta = weight - previous_checkin.weight if previous_checkin
    Checkin.create!(person: person, event: event, weight: weight, delta: delta, user: current_user)
    if person.starting_weight
      person.up_by = weight - person.starting_weight
    else
      person.starting_weight = weight
    end
    person.save!

    return unless current_user
    if !current_user.people.include?(person)
      current_user.user_person_joins.create(person: person)
    elsif current_user.people.include?(person)
      join = current_user.user_person_joins.find_by(person: person)
      join.times_used += 1
      join.save
    end
  end
end