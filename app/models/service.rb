class Service
  include Mongoid::Document

  field :last_refresh, type: DateTime

  belongs_to :user

  has_many :reports
end
