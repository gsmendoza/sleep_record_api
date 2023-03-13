class SleepRecord < ApplicationRecord
  scope :ongoing, -> { where(clocked_out_at: nil) }

  belongs_to :user

  validates :user, presence: true

  validates :clocked_in_at, presence: true
  validates_datetime :clocked_in_at

  validate :ensure_user_has_no_ongoing_sleep_record, on: :create

  def self.new_clock_in(attributes = {})
    new(attributes.merge(clocked_in_at: Time.current))
  end

  def clock_out
    if clocked_out_at.present?
      errors.add :base, :has_already_been_clocked_out

      false
    else
      self.clocked_out_at = Time.current
      save
    end
  end

  private

  def ensure_user_has_no_ongoing_sleep_record
    if user && user.sleep_records.ongoing.any?
      errors.add :base, :has_ongoing_sleep_record
    end
  end
end
