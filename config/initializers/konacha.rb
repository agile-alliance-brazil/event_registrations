# encoding: UTF-8
Konacha.configure do |config|
  WebMock.disable!
  require 'capybara/poltergeist'
  config.driver = :poltergeist
end if defined?(Konacha)
