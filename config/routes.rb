Rails.application.routes.draw do
  match "/first_data/checkout" => "LolitaFirstData::Transaction#checkout", as: "checkout_first_data"
  match "/first_data/answer" => "LolitaFirstData::Transaction#answer", as: "answer_first_data"
  match "/first_data_test/:action" => "LolitaFirstData::Test"
end
