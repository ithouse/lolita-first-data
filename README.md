### INSTALL

- `gem install lolita-first-data`
- `rails g lolita_first_data:install`

### SETUP

For example create model *Payment* and then add these special methods and modify them to suit your needs:
    
    include Lolita::Billing:FirstData

    # Methods for #Lolita::Billing:FirstData
    #---------------------------------------

    # returns integer in cents
    def price
      self.total_price
    end

    # string up to 125 symbols
    # this will included in payment description
    def description
      "Payment to INC Lolipop"
    end

    # returns 3 digit string according to http://en.wikipedia.org/wiki/ISO_4217
    def currency
      "840"
    end
    
    # triggered when FirstData transaction is saved
    def fd_trx_saved trx
      case trx.status
      when 'processing'
        # update_attribute(:status, 'processing')
      when 'completed'
        # update_attribute(:status, 'completed')
      when 'rejected'
        # update_attribute(:status, 'rejected')
      end
    end
    
    # optional
    # this is called when FirstData merchant is taking some actions
    # there you can save the log message other than the default log file
    def log severity, message
      #self.logs.create(:severity => severity, :message => message)
    end
    #---------------------------------------

Generate certificates by running:

    rake first_data:generate_certificate

Use `Lolita::FirstData::TestController` to pass all tests by running server and executing:

    http://localhost:3000/first_data_test/test?nr=1
    http://localhost:3000/first_data_test/test?nr=2
    http://localhost:3000/first_data_test/test?nr=3
    ...

Configure your environments

    # For development.rb and test.rb
    #---------------------

    FD_PEM   = "#{Rails.root}/config/first-data/test.pem"
    FD_PASS  = "qwerty"

    config.after_initialize do
      ActiveMerchant::Billing::Base.mode = :test
    end

When you are ready to pay your payment controller action should end like this:

    @payment = Payment....
    ....
    ....
    session[:first_data] ||= {}
    session[:first_data][:billing_class] = @payment.class.to_s
    session[:first_data][:billing_id]    = @payment.id
    session[:first_data][:finish_path]   = done_payments_path
    redirect_to checkout_first_data_path

### TESTS

Get source and run `rspec spec`