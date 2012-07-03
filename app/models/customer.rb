class Customer < ActiveRecord::Base
  has_many :orders, dependent: :destroy
  accepts_nested_attributes_for :orders
  
  def self.search(search)
  	if search
			words = search.to_s.strip.split
		  words.inject(scoped) do |combined_scope, word|
		    combined_scope.where('LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(transaction_number) LIKE ? OR LOWER(email) LIKE ?',"%#{word.downcase}%","%#{word.downcase}%","%#{word.downcase}%","%#{word.downcase}%")
		  end
  	else
  		return find(:all)
  	end
  end
  
  def 
end
