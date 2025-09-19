class StatsPolicy < Struct.new(:user, :stats)

  attr_reader :user, :stats

  def initialize(user, stats)
    @user = user
    @stats = stats
  end

  def index?
    @user.staff?
  end
end
