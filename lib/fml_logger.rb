module FMLLogger
  def logger
    FMLLogger.logger
  end

  def self.logger
    @logger ||= -> {
      logger = Logger.new(STDERR, level: Logger.const_get(ENV.fetch('FML_LOG_LEVEL') {'ERROR'}))
      logger.formatter = ->(severity, datetime, progname, msg) {Paint[msg+"\n", :blue]}
      
      logger
    }.call
  end
end