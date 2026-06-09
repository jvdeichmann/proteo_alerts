require 'rails_helper'

RSpec.describe RejectAlert do
  describe '.call' do
    context 'quando o alerta está pendente' do
      it 'rejeita e retorna sucesso' do
        alert = create(:monitoring_alert)

        result = described_class.call(alert)

        expect(result).to be_success
        expect(result.value).to be_status_rejected
        expect(alert.reload).to be_status_rejected
      end
    end

    context 'quando o alerta não está pendente' do
      it 'não rejeita um alerta já rejeitado' do
        alert = create(:monitoring_alert, :rejected)

        result = described_class.call(alert)

        expect(result).to be_failure
        expect(result.errors).to include('Alerta só pode ser rejeitado quando está pendente')
      end

      it 'não rejeita um alerta aprovado' do
        alert = create(:monitoring_alert, :approved)

        result = described_class.call(alert)

        expect(result).to be_failure
        expect(alert.reload).to be_status_approved
      end
    end
  end
end
