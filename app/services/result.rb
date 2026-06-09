# Objeto de retorno padrão da camada de domínio.
# Encapsula sucesso/falha + valor + mensagens de erro, evitando
# que controllers precisem inspecionar exceptions ou o estado do model.
class Result
  attr_reader :value, :errors

  def initialize(success:, value: nil, errors: [])
    @success = success
    @value = value
    @errors = Array(errors)
  end

  def success?
    @success
  end

  def failure?
    !success?
  end

  def self.success(value = nil)
    new(success: true, value: value)
  end

  def self.failure(errors)
    new(success: false, errors: errors)
  end
end
