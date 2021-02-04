module ApiResponseHelpers
  extend ActiveSupport::Concern

  def render_multiple_object(success, objects, serializer)
    hash = { success: success, data: [] }
    objects.each do |object|
      serial = serializer.new(object).as_json
      hash[:data].push(serial)
    end
    render json: hash
  end
end
