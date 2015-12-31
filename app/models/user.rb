# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  first_name            :string
#  last_name             :string
#  email                 :string
#  organization          :string
#  phone                 :string
#  country               :string
#  state                 :string
#  city                  :string
#  badge_name            :string
#  cpf                   :string
#  gender                :string
#  twitter_user          :string
#  address               :string
#  neighbourhood         :string
#  zipcode               :string
#  roles_mask            :integer
#  default_locale        :string           default("pt")
#  created_at            :datetime
#  updated_at            :datetime
#  registration_group_id :integer
#

require File.join(Rails.root, 'lib/authorization.rb')
require File.join(Rails.root, 'lib/trimmer.rb')

class User < ActiveRecord::Base
  include Trimmer
  include Authorization

  attr_trimmed    :first_name, :last_name, :email, :organization, :phone, :country, :state, :city,
                  :badge_name, :twitter_user, :address, :neighbourhood, :zipcode

  has_many :authentications

  has_many :attendances
  has_many :events, -> { uniq }, through: :attendances
  has_many :payment_notifications, through: :attendances
  has_many :led_groups, class_name: 'RegistrationGroup', inverse_of: :leader, foreign_key: :leader_id
  has_many :invoices

  has_many :led_groups, class_name: 'RegistrationGroup', inverse_of: :leader, foreign_key: :leader_id

  has_many :invoices

  validates_inclusion_of :default_locale, in: %w(en pt)
  validates_presence_of %i(first_name last_name)
  validates_length_of %i(first_name last_name), maximum: 100, allow_blank: true
  validates_format_of :email, with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, allow_blank: true

  validates_uniqueness_of :email, case_sensitive: false, allow_blank: true

  usar_como_cpf :cpf

  def registrations_for_event(event)
    attendances.select { |attendance| attendance.event_id == event.id }
  end

  def gender=(value)
    self[:gender] = value.nil? ? nil : value == 'M'
  end

  def twitter_user=(value)
    self[:twitter_user] = value.try(:start_with?, '@') ? value[1..-1] : value
  end

  def self.new_from_auth_hash(hash)
    User.new.tap do |user|
      names = extract_names(hash[:info])
      user.first_name = names[0]
      user.last_name = names[-1]
      user.twitter_user = extract_twitter_user(hash)
      %i(email organization phone country state city). each do |attribute|
        user.send("#{attribute}=", hash[:info][attribute])
      end
    end
  end

  def attendance_attributes
    attributes.reject do |attribute, _value|
      %w(id created_at updated_at roles_mask default_locale).include?(attribute)
    end
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def self.extract_names(hash)
    if hash[:name] && (hash[:first_name].nil? || hash[:last_name].nil?)
      hash[:name].split(' ')
    else
      [hash[:first_name], hash[:last_name]]
    end
  end

  def self.extract_twitter_user(hash)
    hash[:provider] == 'twitter' ? hash[:info][:nickname] : hash[:info][:twitter_user]
  end
end
