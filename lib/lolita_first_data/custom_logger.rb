module LolitaFirstData
  # custom log formatter for FirstData gateway
  class LogFormatter < Logger::Formatter
    def call(severity, time, program_name, message)
      "%5s [%s] (%s) %s :: %s\n" % [severity,::I18n.l(time), $$, program_name, message]
    end
  end
end
