require 'rails_helper'

RSpec.describe 'MonitoringAlerts', type: :request do
  let(:person) { create(:person) }

  describe 'POST /monitoring_alerts' do
    context 'com parâmetros válidos' do
      it 'cria o alerta com status pending e retorna 201' do
        expect do
          post '/monitoring_alerts', params: {
            monitoring_alert: { person_id: person.id, kind: 'debit', amount: 150.5, reference_at: 1.day.ago }
          }
        end.to change(MonitoringAlert, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body['status']).to eq('pending')
      end

      it 'ignora status enviado e força pending' do
        post '/monitoring_alerts', params: {
          monitoring_alert: { person_id: person.id, kind: 'pep', status: 'approved', reference_at: 1.day.ago }
        }

        expect(response).to have_http_status(:created)
        expect(response.parsed_body['status']).to eq('pending')
      end
    end

    context 'com parâmetros inválidos' do
      it 'retorna 422 para debit com amount zero' do
        post '/monitoring_alerts', params: {
          monitoring_alert: { person_id: person.id, kind: 'debit', amount: 0, reference_at: 1.day.ago }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['errors']).to include('Valor deve ser maior que 0')
      end

      it 'retorna 422 para reference_at no futuro' do
        post '/monitoring_alerts', params: {
          monitoring_alert: { person_id: person.id, kind: 'pep', reference_at: 1.day.from_now }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['errors']).to include('Data de referência não pode estar no futuro')
      end
    end
  end

  describe 'GET /monitoring_alerts' do
    let!(:debit)    { create(:monitoring_alert, :debit, reference_at: 3.days.ago) }
    let!(:pep)      { create(:monitoring_alert, :pep, :approved, reference_at: 1.day.ago) }
    let!(:sanction) { create(:monitoring_alert, :sanction, reference_at: 2.days.ago) }

    it 'lista todos com metadados de paginação' do
      get '/monitoring_alerts'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data'].size).to eq(3)
      expect(response.parsed_body['meta']).to include('page', 'per_page', 'total_count', 'total_pages')
    end

    it 'filtra por kind' do
      get '/monitoring_alerts', params: { kind: 'debit' }

      expect(response.parsed_body['data'].map { |a| a['kind'] }).to eq(['debit'])
    end

    it 'filtra por status' do
      get '/monitoring_alerts', params: { status: 'approved' }

      expect(response.parsed_body['data'].map { |a| a['id'] }).to eq([pep.id])
    end

    it 'ordena ascendente por reference_at' do
      get '/monitoring_alerts', params: { order: 'asc' }

      expect(response.parsed_body['data'].map { |a| a['id'] }).to eq([debit.id, sanction.id, pep.id])
    end

    it 'pagina os resultados' do
      get '/monitoring_alerts', params: { per_page: 2, page: 1 }

      expect(response.parsed_body['data'].size).to eq(2)
      expect(response.parsed_body['meta']['total_count']).to eq(3)
      expect(response.parsed_body['meta']['total_pages']).to eq(2)
    end
  end

  describe 'PATCH /monitoring_alerts/:id/approve' do
    it 'aprova um alerta pendente (200)' do
      alert = create(:monitoring_alert)

      patch "/monitoring_alerts/#{alert.id}/approve"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['status']).to eq('approved')
    end

    it 'retorna 422 ao aprovar um alerta já aprovado' do
      alert = create(:monitoring_alert, :approved)

      patch "/monitoring_alerts/#{alert.id}/approve"

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to include('Alerta só pode ser aprovado quando está pendente')
    end

    it 'retorna 404 para id inexistente' do
      patch '/monitoring_alerts/999999/approve'

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body['errors']).to include('Registro não encontrado')
    end
  end

  describe 'PATCH /monitoring_alerts/:id/reject' do
    it 'rejeita um alerta pendente (200)' do
      alert = create(:monitoring_alert)

      patch "/monitoring_alerts/#{alert.id}/reject"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['status']).to eq('rejected')
    end

    it 'retorna 422 ao rejeitar um alerta já rejeitado' do
      alert = create(:monitoring_alert, :rejected)

      patch "/monitoring_alerts/#{alert.id}/reject"

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to include('Alerta só pode ser rejeitado quando está pendente')
    end
  end
end
