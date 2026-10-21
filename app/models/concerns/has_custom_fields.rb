module HasCustomFields
  extend ActiveSupport::Concern

  MAX_CUSTOM_FIELDS = 5

  included do
    validate :custom_fields_must_be_valid
  end

  private

  def custom_fields_must_be_valid
    unless custom_fields.is_a?(Array)
      errors.add(:custom_fields, "must be an array")

      return
    end

    if custom_fields.size > MAX_CUSTOM_FIELDS
      errors.add(:custom_fields, "cannot have more than #{MAX_CUSTOM_FIELDS} fields")
    end

    if custom_fields.any? { |field| field["label"].blank? || field["value"].blank? }
      errors.add(:custom_fields, "must have a label and a value")
    end
  end
end
