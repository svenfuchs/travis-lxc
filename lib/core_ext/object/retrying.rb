class Object
  def retrying(options = {})
    options = { :times => 1, :on => Exception }.merge(options || {})

    begin
      return yield
    rescue *options[:on]
      if (options[:times] -= 1) > 0
        sleep options[:sleep].to_f if options[:sleep]
        retry
      end
      raise
    end
  end
end
