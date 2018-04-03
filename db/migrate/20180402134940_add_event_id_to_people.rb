class AddEventIdToPeople < ActiveRecord::Migration
  def up
    add_reference :people, :event, index: true
  end

  def down
    remove_reference :people, :event, index: true
  end
end
