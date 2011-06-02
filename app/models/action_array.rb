module ActionArray
  def where *args
    return self if args.empty?
    self.select do |item|
      keep = true
      args.each do |arg_item|
        if Hash === arg_item
          arg_item.each do |key, value|
            break if !keep
            unless String === key
              key = key.to_s
            end
            key.split(".").each do |attr|
              if !attr.empty?
                item = item.send(attr)
              end
            end
            if Hash === value
              keep = false if value.length > 1 or value.key?(:like)
              keep = item.to_s.include? value[:like].to_s
            else
              keep = (item == value)
            end
          end
        else
          keep = (item == arg_item)
        end
      end
      keep
    end
  end
end

class Array; include ActionArray; end;
