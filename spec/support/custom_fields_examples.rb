RSpec.shared_examples "has custom fields" do
  let(:factory) { described_class.model_name.singular.to_sym }

  describe "custom fields" do
    it "is valid without custom fields" do
      expect(build(factory, custom_fields: [])).to be_valid
    end

    it "is valid with 5 custom fields" do
      fields = Array.new(5) { |i| { "label" => "Label #{i}", "value" => "Value #{i}" } }

      expect(build(factory, custom_fields: fields)).to be_valid
    end

    it "does not allow more than 5 custom fields" do
      fields = Array.new(6) { |i| { "label" => "Label #{i}", "value" => "Value #{i}" } }
      record = build(factory, custom_fields: fields)

      expect(record).not_to be_valid
      expect(record.errors[:custom_fields]).to include("cannot have more than 5 fields")
    end

    it "requires a label and a value on each custom field" do
      record = build(factory, custom_fields: [ { "label" => "Country", "value" => "" } ])

      expect(record).not_to be_valid
      expect(record.errors[:custom_fields]).to include("must have a label and a value")
    end

    it "requires custom fields to be an array" do
      record = build(factory, custom_fields: { "label" => "Country", "value" => "Vietnam" })

      expect(record).not_to be_valid
      expect(record.errors[:custom_fields]).to include("must be an array")
    end
  end
end
