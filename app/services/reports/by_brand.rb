module Reports
  class ByBrand < ApplicationService
    def initialize(range)
      @range = range
    end

    def execute
      brands = Brand.joins(:cards).merge(Card.created_within(@range))
                    .group(:id).order(:name)
                    .select(:id, :name, *Totals::COLUMNS)

      brands.map { |brand| { id: brand.id, name: brand.name }.merge(Totals.summary(brand)) }
    end
  end
end
