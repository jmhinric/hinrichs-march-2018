require 'csv'
namespace :load_csv do
  desc "Load a CSV file"

  task participants: :environment do
    execute(:participants)
  end

  task weighins: :environment do
    execute(:weighins)
  end

  def self.execute(method_name)
    ActiveRecord::Base.transaction do
      send(method_name)
      puts "Completed successfully!"
    end
  rescue => e
    puts e.message
    puts e.backtrace[0..50].join("\n")
  end

  def self.participants
    CSV.foreach("#{Rails.root}/participants.csv", headers: true) do |row|
      datetime = Date.parse(row['Date']).to_datetime.utc.beginning_of_day
      event = Event.where(name: row['Event'], created_at: datetime).first_or_create!
      league = League.where(name: row['League']).first_or_create!
      Person.create!(name: row['Name'], league: league, event: event)
    end
  end

  def self.weighins
    create_checkin_args = []
    CSV.foreach("#{Rails.root}/weighins.csv", headers: true) do |row|
      datetime = DateTime.parse(row['Time'])
      event = Event.find_by!(created_at: datetime.to_date)
      person = Person.find_by!(name: row['Name'], event: event)

      create_checkin_args << [person, event, row['Weight'].to_i, datetime]
    end
    puts "Processed weighins.csv"

    total = create_checkin_args.size
    create_checkin_args
      .sort_by { |w| w.last } # create checkins chronologically
      .each_with_index do |args, i|
        puts "#{i}/#{total}" if i % 200 == 0
        CreateCheckin.call(args[0].reload, *args[1..2], nil)
      end
  end
end
