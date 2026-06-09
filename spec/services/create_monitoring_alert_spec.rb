require 'rails_helper'

RSpec.describe CreateMonitoringAlert do
  let(:person) { create(:person) }

  describe '.call' do
    context 'com atributos válidos' do
      it 'cria o alerta com status pending e retorna sucesso' do
        result = described_class.call(
          person: person, kind: :debit, amount: 100, reference_at: 1.day.ago
        )

        expect(result).to be_success
        expect(result.value).to be_persisted
        expect(result.value).to be_status_pending
      end
    end

    context 'com atributos inválidos' do
      it 'falha quando financeiro sem amount' do
        result = described_class.call(
          person: person, kind: :debit, amount: nil, reference_at: 1.day.ago
        )

        expect(result).to be_failure
        expect(result.errors).to include('Valor não pode ficar em branco')
      end

      it 'falha quando reference_at está no futuro' do
        result = described_class.call(
          person: person, kind: :pep, reference_at: 1.day.from_now
        )

        expect(result).to be_failure
        expect(result.errors).to include('Data de referência não pode estar no futuro')
      end
    end
  end
end
