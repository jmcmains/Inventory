class OfferingProduct < ActiveRecord::Base
  belongs_to :offering, :class_name => "Offering"
  belongs_to :product, :class_name => "Product"
end
