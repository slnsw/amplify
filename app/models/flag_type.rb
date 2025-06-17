# frozen_string_literal: true

class FlagType < ApplicationRecord
  has_paper_trail

  def self.byCategory(category)
    Rails.cache.fetch("flag_types/#{category}", expires_in: 1.day) do
      FlagType.where(category: category)
    end
  end
end
