module UserPoint::Json
  extend ActiveSupport::Concern

  included do

    def to_json(json, options = {})
      json.id         self.id
      json.reason     self.reason
      json.points     self.points
      json.operation  self.operation

      json.user do
        user.to_json json
      end
    end

  end
end
