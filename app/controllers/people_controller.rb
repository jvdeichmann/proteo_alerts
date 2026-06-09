class PeopleController < ApplicationController
  def create
    result = CreatePerson.call(person_params)

    if result.success?
      render json: result.value, status: :created
    else
      render_errors(result.errors, status: :unprocessable_entity)
    end
  end

  private

  def person_params
    params.require(:person).permit(:name, :document)
  end
end
