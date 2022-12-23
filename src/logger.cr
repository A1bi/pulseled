class Logger
  def self.debug(message)
    return unless ENV.fetch("DEBUG", "0") == "1"

    puts message
  end

  private def self.puts(message)
    STDOUT.puts "#{Time.local.to_s("%T")} | #{message}"
  end
end
