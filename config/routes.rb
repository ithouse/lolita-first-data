Rails.application.routes.draw do
  match '/first_data/checkout', :as => "checkout_first_data", :controller => 'Lolita::FirstData::Transaction', :action => 'checkout'
  match '/first_data/answer', :as => "answer_first_data", :controller => 'Lolita::FirstData::Transaction', :action => 'answer'
  match '/first_data_test/:action', :controller => 'Lolita::FirstData::Test'
end