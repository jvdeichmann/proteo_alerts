# Cria um MonitoringAlert. As regras de negócio (amount p/ financeiro,
# reference_at não-futuro) vivem no model e são reportadas via Result.
class CreateMonitoringAlert
  def self.call(attributes)
    new(attributes).call
  end

  def initialize(attributes)
    @attributes = attributes
  end

  def call
    alert = MonitoringAlert.new(@attributes)

    if alert.save
      Result.success(alert)
    else
      Result.failure(alert.errors.full_messages)
    end
  end
end
