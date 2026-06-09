class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private

  # Resposta de erro padronizada em toda a API: { "errors": [ ... ] }
  def render_errors(messages, status:)
    render json: { errors: Array(messages) }, status: status
  end

  def render_not_found(_exception)
    render_errors("Registro não encontrado", status: :not_found)
  end

  def render_bad_request(exception)
    render_errors(exception.message, status: :unprocessable_entity)
  end
end
