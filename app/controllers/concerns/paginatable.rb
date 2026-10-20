module Paginatable
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  def paginate(scope)
    records = scope.limit(page_size).offset((page_number - 1) * page_size)
    [ records, { page: page_number, per_page: page_size, total: scope.count } ]
  end

  private

  def page_number
    [ params[:page].to_i, 1 ].max
  end

  def page_size
    requested = params[:per_page].to_i
    requested = DEFAULT_PER_PAGE if requested < 1

    [ requested, MAX_PER_PAGE ].min
  end
end
