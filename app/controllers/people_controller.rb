class PeopleController < ApplicationController
  def create
    ActiveRecord::Base.transaction do
      @person = Person.create(person_params)
      @league = League.where(name: league_name_params).first_or_create!
      @person.update!(league: @league)
      CreateCheckin.call(@person, Event.last, checkin_params[:weight].to_f, current_user)
    end
    redirect_to people_path
  end

  def index
    @event = Event.includes(:people).last
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
    @person = Person.find(params[:id])
  end

  private
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