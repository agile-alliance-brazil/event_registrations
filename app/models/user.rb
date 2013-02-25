require File.join(Rails.root, 'lib/authorization.rb')
require File.join(Rails.root, 'lib/trimmer.rb')

class User < ActiveRecord::Base
  include Trimmer
  include Authorization
  attr_accessor :roles_mask

  attr_accessible :first_name, :last_name, :email, :organization, :phone,
                  :country, :state, :city, :badge_name, :cpf, :gender, :twitter_user, :address,
                  :neighbourhood, :zipcode, :registration_type_id, :status_event,
                  :event_id, :notes, :payment_agreement, :registration_date, :default_locale
  attr_trimmed    :first_name, :last_name, :email, :organization, :phone, :country, :state, :city,
                  :badge_name, :twitter_user, :address, :neighbourhood, :zipcode, :notes

  has_many :authentications
  
  has_many :event_attendances
  has_many :payment_notifications, :as => :invoicer
  
  validates_presence_of [:first_name, :last_name]
  validates_length_of [:first_name, :last_name], :maximum => 100, :allow_blank => true
  validates_format_of :email, :with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i, :allow_blank => true

  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true

  usar_como_cpf :cpf

  def has_approved_session? event
    false
  end

  def events
    Event.all
  end

  def registrations_for_event(event)
    (event_attendances).select{ |attendance| attendance.event_id == event.id }
  end

  def event_attendances
    []
  end

  def gender=(value)
    write_attribute(:gender, value.nil? ? nil : value == 'M')
  end

  def gender
    value = read_attribute(:gender)
    value.nil? ? nil : (value ? 'M' : 'F')
  end
  
  def twitter_user=(value)
    self[:twitter_user] = value.start_with?("@") ? value[1..-1] : value
  end

  def self.new_from_auth_hash(hash)
    names = hash[:info][:name].split(" ")
    user = User.new(:first_name => names[0],
      :last_name => names[-1],
      :email => hash[:info][:email])
    user
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def male?
    gender == 'M'
  end
end