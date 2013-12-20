class Shipworks < ActiveRecord::Base
  establish_connection "amz_rds_db"
end
