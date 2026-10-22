module Cards
  Result = Struct.new(:card, :error, :replayed, keyword_init: true) do
    def success?
      error.nil?
    end
  end
end
