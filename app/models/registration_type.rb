class RegistrationType < ActiveRecord::Base
  belongs_to :event
  has_many :registration_prices

  scope :without_group, -> { where('title != ?', 'registration_type.group') }
  scope :without_free, -> { where('title != ? AND title != ? AND title != ?', 'registration_type.manual', 'registration_type.free', 'registration_type.speaker') }
  scope :paid, -> { where(title: ['registration_type.individual', 'registration_type.group', 'registration_type.member', 'registration_type.non_member']) }
  scope :individual, -> { where(title: 'registration_type.individual') }

  def price(datetime)
    period = event.registration_periods.for(datetime).first
    period.price_for_registration_type(self)
  end

end
