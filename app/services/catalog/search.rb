module Catalog
  class Search < ApplicationService
    def initialize(client, filters = {})
      @client = client
      @filters = filters
    end

    def execute
      scope = @client.products.available
      scope = by_query(scope)
      scope = by_min_denomination(scope)
      scope = by_max_denomination(scope)

      scope.order(:name)
    end

    private

    def by_query(scope)
      return scope if @filters[:q].blank?

      pattern = "%#{Product.sanitize_sql_like(@filters[:q])}%"

      case @filters[:search_in]
      when "product"
        scope.where("products.name ILIKE ?", pattern)
      when "brand"
        scope.where("brands.name ILIKE ?", pattern)
      else
        scope.where("products.name ILIKE :q OR brands.name ILIKE :q", q: pattern)
      end
    end

    def by_min_denomination(scope)
      return scope if @filters[:min_denomination].blank?

      scope.where(denomination: @filters[:min_denomination]..)
    end

    def by_max_denomination(scope)
      return scope if @filters[:max_denomination].blank?

      scope.where(denomination: ..@filters[:max_denomination])
    end
  end
end
