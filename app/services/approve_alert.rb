# Aprova um alerta. Regra de transição: só é permitido quando status = pending.
# Tentar aprovar um alerta já aprovado/rejeitado é falha de negócio (não exception).
class ApproveAlert
  def self.call(alert)
    new(alert).call
  end

  def initialize(alert)
    @alert = alert
  end

  def call
    unless @alert.status_pending?
      return Result.failure([ "Alerta só pode ser aprovado quando está pendente" ])
    end

    @alert.status_approved!
    Result.success(@alert)
  end
end
