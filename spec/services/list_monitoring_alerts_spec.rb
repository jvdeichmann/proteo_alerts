require 'rails_helper'

RSpec.describe ListMonitoringAlerts do
  let!(:debit)    { create(:monitoring_alert, :debit, reference_at: 3.days.ago) }
  let!(:pep)      { create(:monitoring_alert, :pep, :approved, reference_at: 1.day.ago) }
  let!(:sanction) { create(:monitoring_alert, :sanction, reference_at: 2.days.ago) }

  describe '.call' do
    it 'retorna todos sem filtros' do
      expect(described_class.call).to contain_exactly(debit, pep, sanction)
    end

    it 'filtra por status' do
      expect(described_class.call(status: 'approved')).to contain_exactly(pep)
    end

    it 'filtra por kind' do
      expect(described_class.call(kind: 'debit')).to contain_exactly(debit)
    end

    it 'combina filtros de status e kind' do
      expect(described_class.call(status: 'pending', kind: 'sanction')).to contain_exactly(sanction)
    end

    it 'ordena ascendente por reference_at' do
      expect(described_class.call(order: 'asc')).to eq([debit, sanction, pep])
    end

    it 'ordena descendente por padrão' do
      expect(described_class.call).to eq([pep, sanction, debit])
    end
  end
end
