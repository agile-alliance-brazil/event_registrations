# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  birth_date             :date
#  city                   :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string           indexed
#  confirmed_at           :datetime
#  country                :string
#  created_at             :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  disability             :integer          default("disability_not_informed"), not null, indexed
#  education_level        :integer          default("no_education_informed"), indexed
#  email                  :string           not null, indexed
#  encrypted_password     :string           default(""), not null
#  ethnicity              :integer          default("no_ethnicity_informed"), not null, indexed
#  failed_attempts        :integer          default(0), not null
#  first_name             :string           not null
#  gender                 :integer          default("gender_not_informed"), indexed
#  id                     :integer          not null, primary key
#  last_name              :string           not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  registration_group_id  :integer
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string           indexed
#  role                   :integer          default("user"), not null
#  roles_mask             :integer
#  school                 :string
#  sign_in_count          :integer          default(0), not null
#  state                  :string
#  unconfirmed_email      :string
#  unlock_token           :string           indexed
#  updated_at             :datetime
#  user_image             :string
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_disability            (disability)
#  index_users_on_education_level       (education_level)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_ethnicity             (ethnicity)
#  index_users_on_gender                (gender)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_ebe9fba698  (registration_group_id => registration_groups.id)
#

class User < ApplicationRecord
  enum role: { user: 0, organizer: 1, admin: 2 }
  enum gender: { cisgender_man: 0, transgender_man: 1, cisgender_woman: 2, transgender_woman: 3, non_binary: 4, gender_not_informed: 5 }
  enum education_level: { no_education_informed: 0, primary: 1, secondary: 2, tec_secondary: 3, tec_terciary: 4, bachelor: 5, master: 6, doctoral: 7 }
  enum ethnicity: { no_ethnicity_informed: 0, asian: 1, white: 2, indian: 3, brown: 4, black: 5 }
  enum disability: { no_disability: 0, visually_impairment: 1, hearing_impairment: 2, physical_impairment: 3, mental_impairment: 4, disability_not_informed: 5 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :omniauthable

  devise :omniauthable, omniauth_providers: %i[github facebook twitter]

  mount_uploader :user_image, RegistrationsImageUploader

  has_many :attendances, dependent: :destroy
  has_many :events, -> { distinct }, through: :attendances, dependent: :nullify
  has_many :payment_notifications, through: :attendances, dependent: :destroy
  has_many :led_groups, class_name: 'RegistrationGroup', inverse_of: :leader, foreign_key: :leader_id, dependent: :nullify
  has_many :registered_attendances, class_name: 'Attendance', inverse_of: :registered_by_user, foreign_key: :registered_by_id, dependent: :restrict_with_exception

  has_and_belongs_to_many :organized_events, class_name: 'Event'

  validates :first_name, :last_name, presence: true, length: { maximum: 100 }
  validates :email, format: { with: /\A([\w.%+\-]+)@([\w\-]+\.)+(\w{2,})\z/i, allow_blank: true }
  validates :email, uniqueness: { case_sensitive: false, allow_blank: true }

  def self.from_omniauth(omniauth_params)
    name = omniauth_params.info.name
    where(email: omniauth_params.info.email).first_or_create do |user|
      name_parts = name.split
      user.first_name = name_parts.shift
      user.last_name = if name_parts.empty?
                         user.first_name
                       else
                         name_parts.join(' ')
                       end

      user.password = Devise.friendly_token[0, 20]
    end
  end

  def user_locale
    return 'pt' if country == 'BR' || country == 'PT' || country.blank?

    'en'
  end

  def registrations_for_event(event)
    Attendance.where(id: attendances.select { |attendance| attendance.event_id == event.id }.map(&:id))
  end

  def registrations_for_other_users
    Attendance.where(id: (registered_attendances - attendances).map(&:id)).order(registration_date: :desc)
  end

  def valid_attendance_for_event(event)
    registrations_for_event(event).not_cancelled.first
  end

  def full_name
    [first_name&.titleize, last_name&.titleize].join(' ')
  end

  def organizer_of?(event)
    return false if user?
    return true if admin?

    organized_events.include?(event)
  end

  def toggle_admin
    if admin?
      update(role: :user)
    else
      update(role: :admin)
    end
  end

  def toggle_organizer
    if organizer?
      update(role: :user)
    else
      update(role: :organizer)
    end
  end

  def avatar_valid?
    return false if user_image.blank?

    NetServices.instance.url_found?(user_image.url)
  end
end
