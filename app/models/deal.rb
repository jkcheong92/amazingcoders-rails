class Deal < ActiveRecord::Base
  belongs_to :merchant

  has_many :deal_venues, inverse_of: :deal, dependent: :destroy
  has_many :venues, through: :deal_venues
  has_many :deal_days, :dependent => :destroy
  accepts_nested_attributes_for :deal_days, allow_destroy: true

  # Validate input fields from form
  validates(:title, presence: true)
  validates(:type_of_deal, presence: true)
  validates(:description,presence: true, length: {minimum: 5})
  validates(:start_date, presence: true)
  validates(:expiry_date, presence: true)
  # validates :venues, :presence => {message: "Please ensure that there is at least one venue selected"}
  validates(:t_c, presence: true)
  validates :deal_days, :presence => {message: "Please ensure that there is at least one deal period"}

  # Process input fields and further validate
  validate :future_date
  validate :check_expiry_date
  validate :ensuring_pushed_checked
  validate :ensuring_redeemable_checked
  validate :ensuring_multiple_use_checked

  # Process Methods
  def ensuring_pushed_checked
    errors.add(:pushed, 'Please ensure you selected if you want to push deals to users') if ((pushed == nil) rescue ArgumentError == ArgumentError)
  end

  def ensuring_redeemable_checked
    errors.add(:redeemable, 'Please ensure you selected if you want users to redeem through deal code') if ((redeemable == nil) rescue ArgumentError == ArgumentError)
  end

  def ensuring_multiple_use_checked
    if (redeemable)
      errors.add(:multiple_use, 'Please indicate the number of times the deals can be redeemed per user') if ((multiple_use == nil) rescue ArgumentError == ArgumentError)
    end
  end

  def future_date
    errors.add(:start_date, 'must be at least one day in advance') if ((start_date <= Date.today) rescue ArgumentError == ArgumentError)
  end

  def check_expiry_date
    errors.add(:expiry_date, 'has to be after start date') if ((expiry_date <= start_date) rescue ArgumentError == ArgumentError)
  end
end
