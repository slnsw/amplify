class Page < ApplicationRecord
  has_one :public_page

  validates :page_type, presence: true
  validates :content, uniqueness: true
  validates :page_type, uniqueness: true

  attribute :ignore_callbacks, :boolean, default: false

  after_save do
    handle_callback do
      create_public_page
    end
  end

  private

  def create_public_page
    if published
      public_page = PublicPage.where(page_id: id).first_or_initialize
      public_page.content = content
      public_page.save
    end
  end

  def handle_callback
    yield unless ignore_callbacks
  end
end
