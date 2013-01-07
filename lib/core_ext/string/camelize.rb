class String
  def camelize
    to_s.gsub(/^.{1}|_.{1}/) { |char| char.gsub('_', '').upcase }
  end unless ''.respond_to?(:camelize)
end

