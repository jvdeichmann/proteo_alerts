class AddAmountPositiveCheckToMonitoringAlerts < ActiveRecord::Migration[7.2]
  def change
    # Defesa em profundidade: garante amount > 0 no nível do banco
    # (a validação no model é o controle primário). amount pode ser nulo
    # para alertas não financeiros (pep/sanction).
    add_check_constraint :monitoring_alerts,
                         "amount IS NULL OR amount > 0",
                         name: "monitoring_alerts_amount_positive",
                         if_not_exists: true
  end
end
