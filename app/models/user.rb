require File.join(Rails.root, 'lib/authorization.rb')

class User
  include Authorization
  attr_accessor :roles_mask
  
  def initialize
    roles_mask = 0
  end

  def save!
  end
end