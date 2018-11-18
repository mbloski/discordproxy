class Output
  def self.Info(desc, str)
    Gen('i', desc, str)
  end
  def self.Debug(desc, str)
    Gen('D', desc, str)
  end
  def self.Warning(desc, str)
    Gen('!', desc, str)
  end
  def self.Error(desc, str)
    Gen('E', desc, str)
  end
  private
  def self.Gen(m, desc, str)
    puts "#{Time.now.strftime "%H:%M:%S"} #{m} #{desc[0..7].upcase.rjust(8)} | #{str}"
  end
end
