require 'rails_helper'

RSpec.describe MonitoringAlert, type: :model do
  subject { build(:monitoring_alert) }

  describe 'associations' do
    it { is_expected.to belong_to(:person) }
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:kind)
        .with_values(debit: 0, credit: 1, pep: 2, sanction: 3)
        .with_prefix(true)
    end

    it do
      is_expected.to define_enum_for(:status)
        .with_values(pending: 0, approved: 1, rejected: 2)
        .with_prefix(true)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:reference_at) }

    context 'quando kind é financeiro (debit/credit)' do
      it 'exige amount presente' do
        alert = build(:monitoring_alert, :debit, amount: nil)
        expect(alert).not_to be_valid
        expect(alert.errors[:amount]).to include('não pode ficar em branco')
      end

      it 'exige amount maior que zero' do
        alert = build(:monitoring_alert, :credit, amount: 0)
        expect(alert).not_to be_valid
        expect(alert.errors[:amount]).to include('deve ser maior que 0')
      end

      it 'aceita amount positivo' do
        expect(build(:monitoring_alert, :debit, amount: 10.5)).to be_valid
      end
    end

    context 'quando kind não é financeiro (pep/sanction)' do
      it 'é válido sem amount' do
        expect(build(:monitoring_alert, :pep, amount: nil)).to be_valid
        expect(build(:monitoring_alert, :sanction, amount: nil)).to be_valid
      end
    end

    describe 'reference_at' do
      it 'rejeita data no futuro' do
        alert = build(:monitoring_alert, reference_at: 1.day.from_now)
        expect(alert).not_to be_valid
        expect(alert.errors[:reference_at]).to include('não pode estar no futuro')
      end

      it 'aceita data no passado' do
        expect(build(:monitoring_alert, reference_at: 1.day.ago)).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:pending_debit)    { create(:monitoring_alert, :debit, reference_at: 3.days.ago) }
    let!(:approved_pep)     { create(:monitoring_alert, :pep, :approved, reference_at: 1.day.ago) }
    let!(:pending_sanction) { create(:monitoring_alert, :sanction, reference_at: 2.days.ago) }

    describe '.by_status' do
      it 'filtra pelo status informado' do
        expect(described_class.by_status('approved')).to contain_exactly(approved_pep)
      end

      it 'ignora valor inválido (retorna todos)' do
        expect(described_class.by_status('invalido').count).to eq(3)
      end
    end

    describe '.by_kind' do
      it 'filtra pelo kind informado' do
        expect(described_class.by_kind('debit')).to contain_exactly(pending_debit)
      end
    end

    describe '.ordered_by_reference' do
      it 'ordena ascendente' do
        expect(described_class.ordered_by_reference('asc')).to eq([pending_debit, pending_sanction, approved_pep])
      end

      it 'ordena descendente por padrão' do
        expect(described_class.ordered_by_reference('desc')).to eq([approved_pep, pending_sanction, pending_debit])
      end
    end
  end

  describe '#financial?' do
    it { expect(build(:monitoring_alert, :debit).financial?).to be(true) }
    it { expect(build(:monitoring_alert, :credit).financial?).to be(true) }
    it { expect(build(:monitoring_alert, :pep).financial?).to be(false) }
    it { expect(build(:monitoring_alert, :sanction).financial?).to be(false) }
  end
end
