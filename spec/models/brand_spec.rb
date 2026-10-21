require "rails_helper"

RSpec.describe Brand do
  describe "custom fields" do
    it "is valid without custom fields" do
      expect(build(:brand, custom_fields: [])).to be_valid
    end

    it "is valid with 5 custom fields" do
      fields = Array.new(5) { |i| { "label" => "Label #{i}", "value" => "Value #{i}" } }

      expect(build(:brand, custom_fields: fields)).to be_valid
    end

    it "does not allow more than 5 custom fields" do
      fields = Array.new(6) { |i| { "label" => "Label #{i}", "value" => "Value #{i}" } }
      brand = build(:brand, custom_fields: fields)

      expect(brand).not_to be_valid
      expect(brand.errors[:custom_fields]).to include("cannot have more than 5 fields")
    end

    it "requires a label and a value on each custom field" do
      brand = build(:brand, custom_fields: [ { "label" => "Country", "value" => "" } ])

      expect(brand).not_to be_valid
      expect(brand.errors[:custom_fields]).to include("must have a label and a value")
    end
  end
end

# == Schema Information
#
# Table name: brands
#
#  id            :bigint           not null, primary key
#  custom_fields :jsonb            not null
#  name          :citext           not null
#  state         :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_brands_on_name  (name) UNIQUE
#
