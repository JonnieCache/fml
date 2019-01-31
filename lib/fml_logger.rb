module FMLLogger
  def logger
    FMLLogger.logger
  end

  def self.logger
    @logger ||= -> {
      logger = Logger.new(STDERR, level: fml_log_level)
      logger.formatter = ->(severity, datetime, progname, msg) {Paint[msg+"\n", :blue]}
      
      logger
    }.call
  end
  
  def self.fml_log_level
    Logger.const_get ENV.fetch('FML_LOG_LEVEL') {'ERROR'}.upcase
  end
end
