class EventsController < ApplicationController
  def index
    @events = Event.all.order(:id)
  end

  def show
    @event = Event.find(params[:id])
  end

  def create
    @event = Event.create(event_params)
    redirect_to event_people_path(@event)
  end

  private

  def event_params
    params.require(:event).permit(:name, :tagline)
  end
end
