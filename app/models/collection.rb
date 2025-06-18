class Collection < ApplicationRecord
  has_paper_trail

  include ImageSizeValidation
  include UidValidationOnUpdate
  include Publishable # NOTE: default scope is used to filter published_at
  include UidValidation

  mount_uploader :image, ImageUploader
  acts_as_taggable_on :themes

  has_many :transcripts, -> { order("title asc") }, dependent: :destroy
  belongs_to :vendor
  belongs_to :institution

  validates :vendor, :description, presence: true
  validates :institution_id, presence: true
  validates :uid, :title, presence: true, uniqueness: true
  validate :image_size_restriction
  validate :uid_not_changed
  validates :min_lines_for_consensus, numericality: true, if: -> { min_lines_for_consensus.present? }

  attribute :collection_url_title, :string, default: " View in Library catalogue"

  scope :by_institution, ->(institution_id) { where(institution_id: institution_id) }
  scope :with_published_institution, -> { joins(:institution).where("institutions.hidden = false") }

  before_save :save_consensus_params, if: -> { min_lines_for_consensus.present? }

  def save_consensus_params
    self.max_line_edits = min_lines_for_consensus
    self.min_lines_for_consensus_no_edits = min_lines_for_consensus
    self.min_percent_consensus = min_lines_for_consensus.to_f / (max_line_edits + 1).to_f
  end

  # Class Methods
  def self.getForHomepage
    Rails.cache.fetch("#{ENV['PROJECT_ID']}/collections", expires_in: 10.minutes) do
      Collection.where(project_uid: ENV["PROJECT_ID"]).order("title")
    end
  end

  def self.getForDownloadByVendor(vendor_uid, project_uid)
    vendor = Vendor.find_by(uid: vendor_uid)
    Collection.where("vendor_id = :vendor_id AND vendor_identifier != :empty AND project_uid = :project_uid",
                     { vendor_id: vendor[:id], empty: "", project_uid: project_uid })
  end

  def self.getForUploadByVendor(vendor_uid, project_uid)
    vendor = Vendor.find_by(uid: vendor_uid)
    Collection.where("vendor_id = :vendor_id AND vendor_identifier = :empty AND project_uid = :project_uid",
                     { vendor_id: vendor[:id], empty: "", project_uid: project_uid })
  end

  # Instance Methods
  def to_param
    uid
  end

  def duration
    Rails.cache.fetch("Collection:duration:#{id}", expires_in: 23.hours) do
      transcripts.map(&:duration).inject(0) { |memo, duration| memo + duration }
    end
  end

  def disk_usage
    Rails.cache.fetch("Collection:disk_usage:#{id}", expires_in: 23.hours) do
      transcripts.map(&:disk_usage).
        inject({ image: 0, audio: 0, script: 0 }) do |memo, tu|
          memo[:image] += tu[:image]
          memo[:audio] += tu[:audio]
          memo[:script] += tu[:script]
          memo
        end
    end
  end
end
