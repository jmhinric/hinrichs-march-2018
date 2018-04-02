class CheckinsController < ApplicationController
  before_action :load_event, only: [:create, :new]

  def create
    person = Person.find(checkin_params[:person_id])
    @checkin = CreateCheckin.call(person, @event, checkin_params[:weight].to_f, current_user)
    redirect_to event_people_path(@event)
  rescue => e
    logger.error(e.message)
    flash[:error] = e.message
    redirect_to new_event_checkin_path(@event)
  end

  def new
    @people = Person.all.order(:name)
  end

  private

  def event_id
    params.permit(:event_id)[:event_id]
  end

  def load_event
    @event = Event.find(event_id)
  end

  def checkin_params
    params.require(:checkin).permit(:weight, :person_id)
  end
end