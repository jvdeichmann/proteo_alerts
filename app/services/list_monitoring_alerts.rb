# Query object da listagem: aplica filtros (status, kind) e ordenação por
# reference_at, retornando uma ActiveRecord::Relation. A paginação fica na
# camada HTTP (controller, via limit/offset), pois page/per_page são conceitos
# de transporte — assim o query object permanece reutilizável e testável.
class ListMonitoringAlerts
  def self.call(filters = {})
    new(filters).call
  end

  def initialize(filters)
    @filters = filters || {}
  end

  def call
    MonitoringAlert
      .by_status(@filters[:status])
      .by_kind(@filters[:kind])
      .ordered_by_reference(@filters[:order])
  end
end
