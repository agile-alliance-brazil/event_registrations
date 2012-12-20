require File.join(Rails.root, 'lib/authorization.rb')

class User
  attr_accessor :first_name, :last_name, :username, :email, :phone, :country, :state, :city, :organization, :website_url, :bio

  include Authorization
  attr_accessor :roles_mask
  
  def initialize(*args)
    roles_mask = 0
  end

  def save!
  end

  def has_approved_session? event
    false
  end

  def attributes
    (methods - Object.instance_methods).select{|m| m =~ /=$/}.map(&:to_s).map(&:chop).map{|attr| {attr.to_sym => send(attr)}}.inject(:merge)
  end
end