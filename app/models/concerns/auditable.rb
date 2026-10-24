module Auditable
  extend ActiveSupport::Concern

  IGNORED_COLUMNS = %w[id created_at updated_at].freeze

  included do
    after_create  { audit("create", attributes.transform_values { |value| [ nil, value ] }) }
    after_update  { audit("update", saved_changes) }
    after_destroy { audit("destroy", attributes.transform_values { |value| [ value, nil ] }) }
  end

  private

  def audit(event, changes)
    change_set = changes.except(*IGNORED_COLUMNS)
    return if change_set.empty?

    AuditLog.record(action: "#{model_name.singular}.#{event}", record: self, change_set: change_set)
  end
end
