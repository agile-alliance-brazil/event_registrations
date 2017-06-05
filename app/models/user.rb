# == Schema Information
#
# Table name: users
#
#  address               :string
#  badge_name            :string
#  city                  :string
#  country               :string
#  cpf                   :string
#  created_at            :datetime
#  default_locale        :string           default("pt")
#  email                 :string
#  first_name            :string
#  gender                :string
#  id                    :integer          not null, primary key
#  last_name             :string
#  neighbourhood         :string
#  organization          :string
#  phone                 :string
#  registration_group_id :integer
#  roles_mask            :integer
#  state                 :string
#  twitter_user          :string
#  updated_at            :datetime
#  zipcode               :string
#
# Indexes
#
#  fk_rails_ebe9fba698  (registration_group_id)
#
# Foreign Keys
#
#  fk_rails_ebe9fba698  (registration_group_id => registration_groups.id)
#

require Rails.root.join('lib', 'authorization.rb')
require Rails.root.join('lib', 'trimmer.rb')

class User < ApplicationRecord
  include Trimmer
  include Authorization

  attr_trimmed :first_name, :last_name, :email, :organization, :phone, :country, :state, :city,
               :badge_name, :twitter_user, :address, :neighbourhood, :zipcode

  has_many :authentications

  has_many :attendances
  has_many :events, -> { distinct }, through: :attendances
  has_many :payment_notifications, through: :attendances
  has_many :led_groups, class_name: 'RegistrationGroup', inverse_of: :leader, foreign_key: :leader_id
  has_many :invoices

  has_and_belongs_to_many :organized_events, class_name: 'Event'

  validates :default_locale, inclusion: %w[en pt]
  validates :first_name, :last_name, presence: true, length: { maximum: 100 }
  validates :email, format: { with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, allow_blank: true }
  validates :email, uniqueness: { case_sensitive: false, allow_blank: true }

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
    hash_info = hash[:info]
    user = User.find_by(email: hash_info[:email]) if hash_info[:email].present?

    if user.blank?
      user = User.new
      names = extract_names(hash_info)

      user.first_name = names[0]
      user.last_name = names[-1]
      user.twitter_user = extract_twitter_user(hash)
      %i[email organization phone country state city].each do |attribute|
        user.send("#{attribute}=", hash_info[attribute])
      end
    end

    user
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def organized_user_present?(user)
    organized_events.each do |event|
      return true if event.contains?(user)
    end
    false
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
