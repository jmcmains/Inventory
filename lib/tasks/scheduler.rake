desc "This task is called by the Heroku scheduler add-on"
task :update_inventory => :environment do
  if Time.now.friday?
		puts "Updating Inventory..."
		Event.update_inventory
		puts "done."
	else
		puts "inventory only updated on fridays"
	end
end


