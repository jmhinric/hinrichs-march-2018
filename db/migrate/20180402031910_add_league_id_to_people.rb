class AddLeagueIdToPeople < ActiveRecord::Migration
  def up
    add_reference :people, :league, index: true
  end

  def down
    remove_reference :people, :league, index: true
  end
end
