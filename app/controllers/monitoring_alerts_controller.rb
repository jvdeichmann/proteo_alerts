class MonitoringAlertsController < ApplicationController
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  before_action :set_alert, only: [:approve, :reject]

  def index
    scope = ListMonitoringAlerts.call(filter_params)
    total = scope.count
    records = scope.limit(per_page).offset((page - 1) * per_page)

    render json: {
      data: records,
      meta: {
        page: page,
        per_page: per_page,
        total_count: total,
        total_pages: total.zero? ? 0 : (total.to_f / per_page).ceil
      }
    }, status: :ok
  end

  def create
    result = CreateMonitoringAlert.call(monitoring_alert_params)

    if result.success?
      render json: result.value, status: :created
    else
      render_errors(result.errors, status: :unprocessable_content)
    end
  end

  def approve
    render_transition(ApproveAlert.call(@alert))
  end

  def reject
    render_transition(RejectAlert.call(@alert))
  end

  private

  def set_alert
    @alert = MonitoringAlert.find(params[:id])
  end

  def render_transition(result)
    if result.success?
      render json: result.value, status: :ok
    else
      render_errors(result.errors, status: :unprocessable_content)
    end
  end

  # status não é permitido na criação: todo alerta nasce "pending" e só muda
  # via endpoints de transição (approve/reject).
  def monitoring_alert_params
    params.require(:monitoring_alert).permit(:person_id, :kind, :amount, :reference_at)
  end

  def filter_params
    { status: params[:status], kind: params[:kind], order: params[:order] }
  end

  def page
    @page ||= [params.fetch(:page, 1).to_i, 1].max
  end

  def per_page
    @per_page ||= begin
      value = params.fetch(:per_page, DEFAULT_PER_PAGE).to_i
      value = DEFAULT_PER_PAGE if value <= 0
      [value, MAX_PER_PAGE].min
    end
  end
end
