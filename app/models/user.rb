class User < ApplicationRecord
  has_paper_trail
  # Include default devise modules.
  devise :database_authenticatable,
          :recoverable, :confirmable, :registerable,
          :rememberable, :trackable, :validatable, :omniauthable,
          omniauth_providers: [:google_oauth2, :facebook]

  belongs_to :user_role, optional: true
  belongs_to :institution, optional: true

  attr_accessor :total_edits

  scope :only_public_users, -> { where("user_role_id < ?", UserRole::MIN_STAFF_LEVEL) }
  scope :only_staff_users, -> { where("user_role_id >= ?", UserRole::MIN_STAFF_LEVEL) }

  def incrementLinesEdited(amount=1)
    update(lines_edited: lines_edited + amount)
  end

  def recalculate(edits=nil)
    edits ||= TranscriptEdit.getByUser(id)
    if edits
      update(lines_edited: edits.length)
    end
  end

  def setRole(role_name)
    user_role = UserRole.find_by name: role_name
    if user_role && user_role.id != user_role_id
      update(user_role_id: user_role.id)
    end
  end

  # depriciated method
  def isAdmin?
    role = user_role
    role = UserRole.find user_role_id if !role && user_role_id > 0
    role && role.name == "admin"
  end

  # new admin check
  def admin?
    user_role.try(:name) == "admin"
  end

  # depriciated method
  def isModerator?
    role = user_role
    role = UserRole.find user_role_id if !role && user_role_id > 0
    role && (role.name == "moderator" || role.name == "admin")
  end

  # new method
  def moderator?
    user_role.try(:name) == "moderator"
  end

  def content_editor?
    user_role.try(:name) == "content_editor"
  end


  # can be either,
  # admin, moderator, content_editor
  def staff?
    admin? || moderator? || content_editor?
  end

  def admin_or_content_editor?
    admin? || content_editor?
  end


  def admin_or_moderator?
    admin? || moderator?
  end

  def self.orderByInstitution
    self.includes(:institution).order("institutions.name ASC NULLS FIRST").limit(1000)
  end

  def self.getStatsByDay
    Rails.cache.fetch("#{ENV['PROJECT_ID']}/users/stats", expires_in: 10.minutes) do
      User
        .select('DATE(created_at) AS date, COUNT(*) AS count')
        .group('DATE(created_at)')
        .order('DATE(created_at)')
    end
  end

  # https://github.com/zquestz/omniauth-google-oauth2
  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    unless user
      user = User.new(name: data['name'],
                         email: data['email'],
                         password: Devise.friendly_token[0,20]
                        )
      user.skip_confirmation!
      user.skip_confirmation_notification!
      user.save
    end
    user
  end


end
