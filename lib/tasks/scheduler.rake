desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  puts "Updating Orders..."
  Order.load_from_feed
  puts "done."
end

