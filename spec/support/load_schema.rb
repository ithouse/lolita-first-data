# Add models
ActiveRecord::Schema.define do
  create_table :first_data_transactions do |t|
    t.string :transaction_id, :length => 28
    t.string :transaction_code, :length => 3
    t.string :status, :default => "processing"
    t.references :paymentable, :polymorphic => true
    t.string :ip, :length => 10

    t.timestamps
  end

  create_table :reservations do |t|
    t.integer :full_price
    t.string :status

    t.timestamps
  end
end
