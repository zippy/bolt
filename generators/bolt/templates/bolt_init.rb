# For a list of options that can go in here, see Bolt::Config in:
# vendor/plugins/bolt/lib/bolt/config.rb

Bolt::Initializer.run do |bolt|
  bolt.application_name = 'My Fancy Rails App'
  bolt.email_from = "My App <me@example.com>"
end
