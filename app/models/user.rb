class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,     type: String
  field :username, type: String
  field :email,    type: String

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Database authenticatable
  field :encrypted_password, type: String, default: ''

  # Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  # Rememberable
  field :remember_created_at, type: Time

  # Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def self.columns
    self.fields.collect { |c| c[1] }
  end

  has_many :services
  has_many :reports

  def reports_for_date(date = Date.today)
    self.reports.where(date: date)
  end

  def refresh!
    self.services.each do |service|
      service.refresh!
    end
  end
end
