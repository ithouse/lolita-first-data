Rails.application.routes.draw do
  get '/first_data/checkout' => 'lolita_first_data/transactions#checkout', as: 'checkout_first_data'
  post '/first_data/answer' => 'lolita_first_data/transactions#answer', as: 'answer_first_data'
  get '/first_data/test' => 'lolita_first_data/test#test'
end
