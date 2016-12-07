class Talk < ApplicationRecord

  belongs_to  :team
  belongs_to  :user
  belongs_to  :event_type

  has_many :event_talks
  has_many :events, :through => :event_talks

  has_many  :taggeds, :as => :item
  has_many  :tags, -> { distinct }, :through => :taggeds

  validates :name, presence: true
  validates :event_type, presence: true
  validates :user, presence: true
  validates :team, presence: true

  authorize_values_for :user
  authorize_values_for :event_type
end
