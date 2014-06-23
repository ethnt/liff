class Report
  include Mongoid::Document
  include Mongoid::Timestamps

  field :date, type: Date, default: Date.today # make unique among user's reports

  belongs_to :service
  belongs_to :user
end
