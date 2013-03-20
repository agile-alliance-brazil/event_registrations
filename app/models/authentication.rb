# encoding: UTF-8
class Authentication < ActiveRecord::Base
  PROVIDERS = %w(twitter facebook github)

  belongs_to :user
  attr_accessible :provider, :uid

  validates_presence_of :provider
  validates_presence_of :uid
end
