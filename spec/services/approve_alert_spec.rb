require 'rails_helper'

RSpec.describe ApproveAlert do
  describe '.call' do
    context 'quando o alerta está pendente' do
      it 'aprova e retorna sucesso' do
        alert = create(:monitoring_alert)

        result = described_class.call(alert)

        expect(result).to be_success
        expect(result.value).to be_status_approved
        expect(alert.reload).to be_status_approved
      end
    end

    context 'quando o alerta não está pendente' do
      it 'não aprova um alerta já aprovado' do
        alert = create(:monitoring_alert, :approved)

        result = described_class.call(alert)

        expect(result).to be_failure
        expect(result.errors).to include('Alerta só pode ser aprovado quando está pendente')
        expect(alert.reload).to be_status_approved
      end

      it 'não aprova um alerta rejeitado' do
        alert = create(:monitoring_alert, :rejected)

        result = described_class.call(alert)

        expect(result).to be_failure
        expect(alert.reload).to be_status_rejected
      end
    end
  end
end
