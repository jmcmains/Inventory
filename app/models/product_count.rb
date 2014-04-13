class ProductCount < ActiveRecord::Base
  belongs_to :event, :class_name => "Event"
	belongs_to :product, :class_name => "Product"

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    inv = Event.create!(event_type: "Inventory",date: Date.today)
    spreadsheet.each_with_index do |row,index|
      if index != 0
        product=Product.where(sku: row[1]).first
        create!(event_id: inv.id, product_id: product.id, is_box:false, count: row[4])
      end
    end
  end
  
  def self.open_spreadsheet(file)
    require 'roo'
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path)
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

	def product_name
  	product.try(:name)
  end
  
  def product_name=(name)
  	self.product = Product.where(name: name).first_or_create if name.present?
  end
  
  def box_count=(bcount)
  	if self.count.blank?
  		self.count = ((bcount.to_f.blank? ? 0 : bcount.to_f) * (self.product.per_box.blank? ? 1 : self.product.per_box))
  	else
  		self.count += ((bcount.to_f.blank? ? 0 : bcount.to_f) * (self.product.per_box.blank? ? 1 : self.product.per_box))
  	end
  end
  
  def box_count
  	if is_box
  		count
  	else
  		(self.count/(self.product.per_box.blank? ? 1 : self.product.per_box)).floor
  	end
  end
  
  def piece_count=(pcount)
		if self.count.blank?
  		self.count = (pcount.to_f.blank? ? 0 : pcount.to_f)
  	else
  		self.count += (pcount.to_f.blank? ? 0 : pcount.to_f)
  	end
  end
  
  def piece_count
  	if is_box
  		0
  	else
  		self.count-((self.count/(self.product.per_box.blank? ? 1 : self.product.per_box)).floor*(self.product.per_box.blank? ? 1 : self.product.per_box))
  	end
  end
  
  def product_image
  	product.try(:imloc)
  end
  
  def product_image=(imloc)
  	self.product = Product.where(imloc: imloc).first_or_create if imloc.present?
  end
  
  def product_description
  	product.try(:description)
  end
  
  def product_description=(description)
  	self.product = Product.where(description: description).first_or_create if description.present?
  end
  
  def product_description
  	product.try(:description)
  end
  
end
