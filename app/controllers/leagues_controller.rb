class LeaguesController < ApplicationController
  def show
    @event = Event.includes(people: :league).find(event_id)
    @league = League.find(league_id)
    @people = @event.people.where(league: @league)
  end

  private

  def event_id
    params.permit(:event_id)[:event_id]
  end

  def league_id
    params.permit(:id)[:id]
  end
end