class AddRoot < ActiveRecord::Migration
  def self.up
    r = Role.new(:name => "admin")
    r.save
    User.new(:email => "root@mail.com",
             :password => "saroot",
             :password_confirmation => "saroot",
             :username => "root",
             :role_ids => [r.id]).save
  end

  def self.down
    User.where(:email => "root@mail.com").first.delete
  end
end
