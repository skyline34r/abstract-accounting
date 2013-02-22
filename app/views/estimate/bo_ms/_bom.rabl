attributes :uid, :amount, :resource_id
child(:resource => :resource) { attributes :tag, :mu }