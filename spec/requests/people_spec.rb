require 'rails_helper'

RSpec.describe 'People', type: :request do
  describe 'POST /people' do
    context 'com parâmetros válidos' do
      it 'cria a pessoa e retorna 201' do
        expect do
          post '/people', params: { person: { name: 'Ana', document: '12345678901' } }
        end.to change(Person, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body['name']).to eq('Ana')
      end
    end

    context 'com parâmetros inválidos' do
      it 'retorna 422 com erros em pt-BR' do
        post '/people', params: { person: { name: '', document: '' } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['errors']).to include('Nome não pode ficar em branco')
      end

      it 'retorna 422 para document duplicado' do
        create(:person, document: '12345678901')

        post '/people', params: { person: { name: 'Bia', document: '12345678901' } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['errors']).to include('Documento já está em uso')
      end
    end

    context 'sem o root param person' do
      it 'retorna 400 (bad request)' do
        post '/people', params: {}

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['errors']).to be_present
      end
    end
  end
end
