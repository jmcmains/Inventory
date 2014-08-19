output=Hash.from_xml(fis.list_inbound_shipments(shipment_status_list: "CLOSED").body)

shipment_ids=output["ListInboundShipmentsResponse"]["ListInboundShipmentsResult"]["ShipmentData"]["member"].map { |a| a["ShipmentId"] }


shipment_status_list= ['WORKING','SHIPPED','IN_TRANSIT','DELIVERED','CHECKED_IN','RECEIVING','CLOSED','CANCELLED','DELETED','ERROR']
