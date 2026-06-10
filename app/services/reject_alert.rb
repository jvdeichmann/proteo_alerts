# Rejeita um alerta. Regra de transição: só é permitido quando status = pending.
class RejectAlert
  def self.call(alert)
    new(alert).call
  end

  def initialize(alert)
    @alert = alert
  end

  def call
    # with_lock abre transação + trava a linha: dois rejects simultâneos
    # são serializados, evitando que ambos vejam o alerta como pending.
    @alert.with_lock do
      unless @alert.status_pending?
        return Result.failure([ "Alerta só pode ser rejeitado quando está pendente" ])
      end

      @alert.status_rejected!
    end

    Result.success(@alert)
  end
end
