# frozen_string_literal: true

StatsPolicy = Struct.new(:user, :stats) do
  attr_reader :user, :stats

  def initialize(user, stats)
    @user = user
    @stats = stats
  end

  def index?
    @user.staff?
  end
end
