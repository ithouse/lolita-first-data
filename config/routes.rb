ActionController::Routing::Routes.draw do |map|
  map.checkout_first_data '/first_data/checkout', :controller => 'Lolita::FirstData::Transaction', :action => 'checkout'
  map.answer_first_data   '/first_data/answer'  , :controller => 'Lolita::FirstData::Transaction', :action => 'answer'
  map.connect '/first_data_test/:action', :controller => 'Lolita::FirstData::Test'
end