module EntriesHelper
  def entry_error_messages(entry, picks)
    general = entry.errors.reject do |error|
      error.attribute.to_s.start_with?('picks.') || (error.attribute == :picks && error.type == :invalid)
    end.map(&:full_message)

    rows = picks.select { |pick| pick.errors.any? }.map do |pick|
      "#{pick.category.name}: #{pick.errors.full_messages.to_sentence.downcase_first}"
    end

    hidden = (entry.picks.to_a - picks).any? { |pick| pick.errors.any? }
    hidden_message = hidden ? ['Some picks are for categories outside this ceremony'] : []

    (general + rows + hidden_message).uniq
  end
end
