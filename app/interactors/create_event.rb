class CreateEvent

  def self.call(name, tagline)
    Event.create(name: name, tagline: tagline)
  end
end