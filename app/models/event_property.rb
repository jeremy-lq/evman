class EventProperty < ApplicationRecord
  module Behaviour
    MULTIPLE_CHOICE = 'multiple_choice'
    SELECT = 'select'
    TEXT = 'text'
  end
  BEHAVIOURS = [
      Behaviour::MULTIPLE_CHOICE,
      Behaviour::SELECT,
      Behaviour::TEXT
  ]

  belongs_to :team
  has_many :options, class_name: 'EventPropertyOption', inverse_of: :property, dependent: :destroy, foreign_key: :property_id

  validates :behaviour, inclusion: BEHAVIOURS
  validates :name, presence: true, uniqueness: { scope: :team_id }

  def selected_options(event)
    return [] if new_record?
    return [] if event.properties_assignments.blank?
    values = event.properties_assignments[id.to_s]
    return [] if values.blank?

    # search through array if options are eager loaded
    if options.loaded?
      options.select{ |option| values.include?(option.id.to_s) }
    else
      options.where(id: values)
    end
  end

  def value(event)
    return nil if new_record?
    return nil if event.properties_assignments.blank?
    event.properties_assignments[id.to_s].first
  end

  def allows_options?
    [Behaviour::MULTIPLE_CHOICE, Behaviour::SELECT].include? behaviour
  end

  def events
    team.events.jsonb_where(:properties_assignments, {id => []})
  end

  private
  after_destroy :clear_event_assignments
  def clear_event_assignments
    events.update_all("properties_assignments = (properties_assignments - '#{id}')")
  end

  before_validation :set_position
  def set_position
    return unless new_record?
    self.position = (team.event_properties.maximum(:position) || 0) + 1
  end
end
