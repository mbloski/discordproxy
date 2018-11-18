require 'timeout'
require './output'
class Eval
  def self.do_eval command
    begin
      begin
        Timeout::timeout(5) do
          Output.Debug "EVAL", command
          ret = eval(command)

          if not ret.instance_of? String
            ret = ret.inspect
          end

          return ret
        end
      rescue Timeout::Error
        return "Timeout"
      end
    rescue Exception => err
      return err.to_s
    end
  end
end
