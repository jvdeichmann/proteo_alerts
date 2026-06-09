# Rejeita um alerta. Regra de transição: só é permitido quando status = pending.
class RejectAlert
  def self.call(alert)
    new(alert).call
  end

  def initialize(alert)
    @alert = alert
  end

  def call
    unless @alert.status_pending?
      return Result.failure([ "Alerta só pode ser rejeitado quando está pendente" ])
    end

    @alert.status_rejected!
    Result.success(@alert)
  end
end
