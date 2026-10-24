module Reports
  class ByBrand < ApplicationService
    def initialize(range, filters)
      @range = range
      @filters = filters
    end

    def execute
      brands = Brand.joins(:cards).merge(Card.created_within(@range))
                    .group(:id).order(:name)
                    .select(:id, :name, *Totals::COLUMNS)
      brands = brands.where(id: @filters[:brand_id]) if @filters[:brand_id].present?

      brands.map { |brand| { id: brand.id, name: brand.name }.merge(Totals.summary(brand)) }
    end
  end
end
