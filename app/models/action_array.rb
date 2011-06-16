module ActionArray
  def call_sub_attributes name, item
    name.split(".").each do |attr|
      break if item.nil?
      if !attr.empty? and (item.methods.include?(attr.to_sym) or
          (item.methods.include?(:has_attribute?) and item.has_attribute?(attr)))
        item = item.send(attr)
      else
        item = nil
      end
    end
    item
  end

  def where *args
    return self if args.empty?
    self.select do |entry|
      keep = true
      args.each do |arg_item|
        if Hash === arg_item
          arg_item.each do |key, value|
            item = entry
            break if !keep
            unless String === key
              key = key.to_s
            end
            item = self.call_sub_attributes key, item
            if !item.nil?
              if Hash === value
                keep = false if value.length > 1 or value.key?(:like)
                keep = item.to_s.include? value[:like].to_s
              else
                keep = (item == value)
              end
            else
              keep = false
            end
          end
        else
          keep = (entry == arg_item)
        end
      end
      keep
    end
  end

  def order *args
    return self if args.empty?
    arg = args.first
    order = 'asc'
    param = nil
    if String === arg
      order = arg
    elsif Hash === arg
      arg.each do |key, value|
        param = key
        order = value.to_s
      end
    end
    return self if !param.nil? and param.empty?
    p = Proc.new do |a, b|
      a = param.nil? ? a : self.call_sub_attributes(param, a)
      b = param.nil? ? b : self.call_sub_attributes(param, b)
      if a.nil? or (!b.nil? and a < b)
        -1
      elsif !a.nil? and !b.nil? and a == b
        0
      elsif b.nil? or (!a.nil? and a > b)
        1
      end
    end
    if order == 'asc'
      self.sort! do |a,b|
        p.call a, b
      end
    elsif order == 'desc'
      self.sort! do |b,a|
        p.call a, b
      end
    end
    self
  end
end

class Array; include ActionArray; end;
