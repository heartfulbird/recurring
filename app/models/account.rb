class Account < ActiveRecord::Base
  devise :registerable
  self.inheritance_column = :account_type
  
  alias_attribute :address_1, :ship_to_address_1
  alias_attribute :address_2, :ship_to_address_2
  alias_attribute :city,      :ship_to_city
  alias_attribute :state,     :ship_to_state
  alias_attribute :zip,       :ship_to_zip
  alias_attribute :phone,     :ship_to_phone
  alias_attribute :fax,       :ship_to_fax
  # scope :customers, -> { where(:account_type => "Customer")}
  # scope :vendors, -> { where(:account_type => "Vendor")}
  # 
  # def self.account_types
  #   %w(Customer Vendor)
  # end
  
  belongs_to :user
  has_many :contacts
  has_many :equipment, :class_name => "Equipment"
  has_many :charges
  has_many :receipts
  has_many :payment_plans
  has_many :invoices
  has_many :credit_cards
  has_many :orders
  has_many :account_item_prices
  #   
  validates :name, :presence => true
  validates :ship_to_address_1, :presence => true
  validates :ship_to_city, :presence => true
  validates :ship_to_state, :presence => true
  validates :ship_to_zip, :presence => true
  
  def payment_terms
    90
  end
  
  # before_create :set_billing_start_and_day
  # after_create  :set_up_payment_plans
  
  # Billing days range from 1-28
  # def set_billing_start_and_day
  #   date = Date.today + self.demo_period.to_i
  #   self.billing_start ||= date
  #   self.billing_day   ||= [date.day, 28].min
  # end

  # def set_up_payment_plans
  #   self.payment_plans = PaymentPlanTemplate.all.map(&:to_plan)
  # end
  
  # def billing_period(date)
  #   billing_period_start_date_for(date)..billing_period_end_date_for(date)
  # end

  # def billing_period_start_date_for(date)
  #     year, month = if date.day < billing_day
  #       [(date - 1.month).year, (date - 1.month).month]
  #     else
  #       [date.year, date.month]
  #     end
  #     
  #     Date.new(year, month, billing_day)
  #   end
  
  #   def billing_period_end_date_for(date)
  #     year, month = if date.day < billing_day
  #       [date.year, date.month]
  #     else
  #       [(date + 1.month).year, (date + 1.month).month]
  #     end
  #     
  #     Date.new(year, month, billing_day) - 1.day
  #   end
  
end