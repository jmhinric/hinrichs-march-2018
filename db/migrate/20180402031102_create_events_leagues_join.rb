class CreateEventsLeaguesJoin < ActiveRecord::Migration
  def change
    create_table :events_leagues do |t|
      t.references :league, index: true, null: false
      t.references :event, index: true, null: false
      t.timestamps
    end
  end
end
