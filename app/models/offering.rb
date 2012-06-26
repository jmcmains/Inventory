class Offering < ActiveRecord::Base
  has_many :orders, :foreign_key => "offering_id"
  has_many :offering_products, :foreign_key => "offering_id", :dependent => :destroy
  has_many :products, through: :offering_products
  accepts_nested_attributes_for :offering_products, :reject_if => :all_blank, :allow_destroy => true
  validates :name, presence: true
  
  def self.search(search)
  	if search
  		all(conditions: ['name LIKE ?',"%#{search}%"])
  	else
  		return find(:all)
  	end
  end
end
