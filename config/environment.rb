# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Abstract::Application.initialize!

ActionMailer::Base.smtp_settings = {
  :tls => true,
  :address => 'smtp.gmail.com',
  :port => '587',
  :domain => 'mail.google.com',
  :authentication => :plain,
  :user_name => 'username@gmail.com',
  :password => 'password'
}
