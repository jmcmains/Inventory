# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

puts "Importing skus..."

CSV.foreach(Rails.root.join('db/skus.csv'), headers: false) do |row|
  Product.find(row[0]).update_attributes(sku: row[1])
end

