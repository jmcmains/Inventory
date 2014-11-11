class Event < ActiveRecord::Base
  has_many :product_counts, :foreign_key => "event_id", :dependent => :destroy
  has_many :products, through: :product_counts
  has_many :offerings, through: :product_counts
  accepts_nested_attributes_for :product_counts, :reject_if => proc { |attributes| attributes['count'].blank?}, :allow_destroy => true
  belongs_to :supplier, :class_name => "Supplier"
  accepts_nested_attributes_for :supplier, :allow_destroy => true
  
  scope :inventory, -> { where(event_type: "Inventory") }
  scope :unreceived, -> { where(event_type: "Product Order", received: false) }
  scope :received, -> { where(event_type: "Product Order", received: true) }
  scope :product_orders, -> { where(event_type: "Product Order") }


def per_unit_cost
	count = 0
	product_counts.each do |pc|
		if pc.is_box
			count = count + pc.count * Product.find(pc.product_id).per_box
		else
			count = count +pc.count
		end
	end
	return (additional_cost ? additional_cost : 0) /count
end

def self.load_fba_shipment(infile,event_type,date)
	i=0
	event=Event.create!(date: date, event_type: event_type, expected_date: date+1.month, received_date: date+1.month, received: false)
	CSV.parse(infile, col_sep: "\t") do |row|
		if i == 0
			event.update_attributes(invoice: row[1])
		end
		if i>7
			#Merchant SKU		Title		ASIN		FNSKU		external-id		Condition		Shipped
			sku=Sku.where(name: row[0]).first_or_create
			ProductCount.create!(sku_id: sku.id,event_id: event.id,count: row[6], is_box: false)
		end
		i=i+1
	end
end

def self.update_inventory
	event=new(date: Date.today, event_type: "Inventory")
  inv=Product.get_sv_inventory
  Product.all.sort_by(&:name).each do |p|
    event.product_counts.build(attributes: { product_id: p.id, count: inv["#{p.id}"], is_box: false })
  end
  event.save!
end

def supplier_name
  	supplier.try(:name)
  end
  
  def supplier_name=(name)
  	self.supplier = Supplier.find_or_create_by(name: name) if name.present?
  end

protected

    def check_product_count(product_count_attr)
			
      if product_count_attr['count'].blank?
      	rval ||= true
      else
      	rval ||= false
      end
      
      return rval
    end
end

