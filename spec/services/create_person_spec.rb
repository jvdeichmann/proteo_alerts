require 'rails_helper'

RSpec.describe CreatePerson do
  describe '.call' do
    context 'com atributos válidos' do
      it 'cria a pessoa e retorna sucesso' do
        result = described_class.call(name: 'Ana', document: '12345678901')

        expect(result).to be_success
        expect(result.value).to be_persisted
        expect(result.value.name).to eq('Ana')
      end
    end

    context 'com atributos inválidos' do
      it 'não cria e retorna os erros' do
        result = described_class.call(name: '', document: '')

        expect(result).to be_failure
        expect(result.value).to be_nil
        expect(result.errors).to include('Nome não pode ficar em branco')
      end

      it 'falha com document duplicado' do
        create(:person, document: '99999999999')
        result = described_class.call(name: 'Bia', document: '99999999999')

        expect(result).to be_failure
        expect(result.errors).to include('Documento já está em uso')
      end
    end
  end
end
