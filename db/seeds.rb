APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")

if Role.where(:name => "admin").count < 1 then
  Role.new(:name => "admin").save
end

if User.where(:entity_id => 0).count < 1 then
  User.new(:email => APP_CONFIG['email'],
           :password => APP_CONFIG['password'],
           :password_confirmation => APP_CONFIG['password'],
           :entity_id => 0,
           :role_ids => [Role.where(:name => "admin").first.id]).save
else
  User.where(:entity_id => 0).map do |c|
    if c.email != APP_CONFIG['email'] then
      c.delete
    end
  end
end
