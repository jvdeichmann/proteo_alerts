FactoryBot.define do
  factory :monitoring_alert do
    person
    kind { :debit }
    amount { 100.0 }
    status { :pending }
    reference_at { 1.day.ago }

    trait :debit do
      kind { :debit }
      amount { 100.0 }
    end

    trait :credit do
      kind { :credit }
      amount { 250.0 }
    end

    trait :pep do
      kind { :pep }
      amount { nil }
    end

    trait :sanction do
      kind { :sanction }
      amount { nil }
    end

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end
