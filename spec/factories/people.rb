FactoryBot.define do
  factory :person do
    sequence(:name) { |n| "Person #{n}" }
    sequence(:document) { |n| format("%011d", n) }
  end
end
