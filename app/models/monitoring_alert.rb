class MonitoringAlert < ApplicationRecord
  belongs_to :person

  enum :kind, { debit: 0, credit: 1, pep: 2, sanction: 3 }, prefix: true
  enum :status, { pending: 0, approved: 1, rejected: 2 }, prefix: true

  validates :kind, presence: true
  validates :reference_at, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }, if: :financial?

  validate :reference_at_not_in_future

  # Filtros tolerantes: valor inválido/ausente não quebra a cadeia de scopes,
  # apenas não restringe o resultado (retorna a relation completa).
  scope :by_status, ->(value) { statuses.key?(value.to_s) ? where(status: value) : all }
  scope :by_kind, ->(value) { kinds.key?(value.to_s) ? where(kind: value) : all }
  scope :ordered_by_reference, ->(direction) do
    dir = direction.to_s.downcase == "asc" ? :asc : :desc
    # id como desempate garante ordem estável entre páginas quando há
    # reference_at iguais (evita registros "pulando" de página).
    order(reference_at: dir, id: dir)
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
