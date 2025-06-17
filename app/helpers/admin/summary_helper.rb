# frozen_string_literal: true

module Admin
  module SummaryHelper
    include Admin::StatsHelper

    # @see https://gist.github.com/shunchu/3175001#gistcomment-2197179
    def duration_to_hms(total_seconds)
      {
        h: total_seconds / (60 * 60),
        m: (total_seconds / 60) % 60,
        s: total_seconds % 60
      }.map do |suffix, time|
        # Right justify and pad with 0 until length is 2.
        # So if the duration of any of the time components is 0,
        # then it will display as 00.
        "#{time.round.to_s.rjust(2, '0')}#{suffix}"
      end.join(' ')
    end
  end
end
