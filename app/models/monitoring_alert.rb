class MonitoringAlert < ApplicationRecord
  belongs_to :person

  enum :kind, { debit: 0, credit: 1, pep: 2, sanction: 3 }, prefix: true
  enum :status, { pending: 0, approved: 1, rejected: 2 }, prefix: true

  validates :kind, presence: true
  validates :status, presence: true
  validates :reference_at, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }, if: :financial?

  validate :reference_at_not_in_future

  scope :by_status, ->(value) { where(status: value) if value.present? }
  scope :by_kind, ->(value) { where(kind: value) if value.present? }
  scope :ordered_by_reference, ->(direction) do
    order(reference_at: direction.to_s.downcase == "asc" ? :asc : :desc)
  end

  def financial?
    kind_debit? || kind_credit?
  end

  private

  def reference_at_not_in_future
    return if reference_at.blank?

    errors.add(:reference_at, "não pode estar no futuro") if reference_at > Time.current
  end
end
