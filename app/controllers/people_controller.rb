class PeopleController < ApplicationController
  before_action :load_event, only: [:create, :new]

  def new
  end

  def create
    ActiveRecord::Base.transaction do
      @person = Person.create(person_params)
      @league = League.where(name: league_name_params).first_or_create!
      @person.update!(league: @league)
      CreateCheckin.call(@person, @event, checkin_params[:weight].to_f, current_user)
    end
    redirect_to event_people_path
  end

  def index
    @event = Event.includes(people: :league).find(event_id)
    unless @event
      redirect_to new_event_path
    end
    people = @event.people
    @ranked_people = people
      .select { |p| p.up_by }
      .sort_by { |p| [ p.up_by, p.percentage_change ] }
      .reverse
    @unranked_people = people - @ranked_people
  end

  def show
    @event = Event.find(params[:event_id])
    @person = Person.find(params[:id])
  end

  private

  def event_id
    params.permit(:event_id)[:event_id]
  end

  def load_event
    @event = Event.find(event_id)
  end

  def person_params
    params.required(:person).permit([:name])
  end

  def league_name_params
    params.required(:person).permit([:league_name])[:league_name]
  end

  def checkin_params
    params.required(:person).permit([:weight])
  end
end