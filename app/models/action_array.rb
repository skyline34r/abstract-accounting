module ActionArray
  def call_sub_attributes name, item
    name.split(".").each do |attr|
      break if item.nil?
      if !attr.empty?
        item = item.send(attr)
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
            if Hash === value
              keep = false if value.length > 1 or value.key?(:like)
              keep = item.to_s.include? value[:like].to_s
            else
              keep = (item == value)
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
    return self if param.nil? or param.empty?
    if order == 'asc'
      self.sort! do |a,b|
        a = param.nil? ? a : self.call_sub_attributes(param, a)
        b = param.nil? ? b : self.call_sub_attributes(param, b)
        a  <=> b
      end
    elsif order == 'desc'
      self.sort! do |b,a|
        a = param.nil? ? a : self.call_sub_attributes(param, a)
        b = param.nil? ? b : self.call_sub_attributes(param, b)
        a  <=> b
      end
    end
    self
  end
end

class Array; include ActionArray; end;
