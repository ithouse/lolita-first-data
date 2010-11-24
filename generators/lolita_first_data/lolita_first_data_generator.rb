class LolitaFirstDataGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
    usage if @args.first == "help"
  end

  def manifest
    record do |m|
      m.migration_template "first_data_payments.erb", "db/migrate", :migration_file_name => "create_first_data_payments"
    end
  end
end