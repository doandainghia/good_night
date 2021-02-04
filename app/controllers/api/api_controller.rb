module Api
  class ApiController < ApplicationController
    include ApiResponseHelpers

    skip_before_action :verify_authenticity_token

    rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found

    def render_record_not_found
      render json: { success: false, errors: "record not found" }, status: 404
    end
  end
end
