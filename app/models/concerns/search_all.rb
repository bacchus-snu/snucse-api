module SearchAll
  extend ActiveSupport::Concern

  EXCLUDED_ATTRIBUTES = %w[password_digest legacy_password_digest].freeze

  def as_indexed_json(options = {})
    as_json(options).tap do |json|
      json['search_all'] = attributes.except(*EXCLUDED_ATTRIBUTES).values.compact.map(&:to_s).join(' ')
    end
  end
end
