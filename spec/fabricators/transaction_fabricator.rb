Fabricator(:transaction, class_name: "Lolita::FirstData::Transaction") do
  transaction_id "D6zNpp/BJnC1y2wZntm4D8XrB2g="
  transaction_code ""
  status 'processing'
  paymentable! :fabricator => :reservation
  ip "100.100.100.100"
end