# Cria uma Person, retornando um Result com o registro ou os erros de validação.
class CreatePerson
  def self.call(attributes)
    new(attributes).call
  end

  def initialize(attributes)
    @attributes = attributes
  end

  def call
    person = Person.new(@attributes)

    if person.save
      Result.success(person)
    else
      Result.failure(person.errors.full_messages)
    end
  end
end
