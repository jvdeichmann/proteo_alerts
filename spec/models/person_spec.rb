require 'rails_helper'

RSpec.describe Person, type: :model do
  subject { build(:person) }

  describe 'associations' do
    it { is_expected.to have_many(:monitoring_alerts).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:document) }

    it 'valida unicidade do document' do
      create(:person, document: '12345678901')
      duplicate = build(:person, document: '12345678901')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:document]).to include('já está em uso')
    end
  end
end
