module LolitaFirstData
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Lolita::Generators::FileHelper
      source_root File.expand_path("../templates", __FILE__)
      desc "Create migrations. "

      def copy_migration
        copy_file "migration.rb", "db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_create_lolita_first_data_transaction.rb"
      end
     
    end
  end
end
