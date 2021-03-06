class OrderLineItem < ActiveRecord::Base
  
  default_scope { order(:order_line_number) }
  
  belongs_to :order, :touch => true
  belongs_to :item
  belongs_to :cart, :class_name => :order, :foreign_key => :order_id
  has_many :line_item_shipments
  has_many :line_item_fulfillments
  
  scope :by_item, -> (item) { where(:item_id => item) }
  scope :active,  -> () { where(:quantity => 1..Float::INFINITY) }
  # scope :unfulfilled, -> { where.not(:id => LineItemFulfillment.pluck(:order_line_item_id).uniq) }
  # scope :fulfilled, -> () { where(:id => LineItemFulfillment.where(:order_line_item_id => self.id).group(:order_line_item_id).sum(:quantity_fulfilled).pluck(:order_line_item_id).uniq) }
  
  before_create :make_line_number, :on => :create
  
  validates :order_line_number, :uniqueness => {
    :scope => :order_id
  }
  
  validates :item_id, :uniqueness => {
    :scope => :order_id
  }
  
  validates :item_id, :presence => true
  
  after_commit :update_shipped_fulfilled
  after_commit :flush_cache
  
  def update_shipped_fulfilled
    qs = calculate_quantity_shipped
    qf = calculate_quantity_fulfilled
    self.update_columns(:quantity_shipped => qs, :quantity_fulfilled => qf)
  end
  
  def item_number
    item.try(:number)
  end
  
  def item_number=(name)
    puts name
    self.item = Item.find_by(:number => name) if name.present?
    puts self.item.number
  end
  
  def flush_cache
    Rails.cache.delete("open_orders")
  end
  
  def make_line_number
    if self.order_id.blank?
    else
      self.order_line_number = self.order.order_line_items.count + 1
    end
  end
  
  def actual_quantity
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_actual_quantity"]) {
      quantity.to_f - quantity_canceled.to_f
    }
  end
  
  def sub_total
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}_sub_total"]) {
      actual_quantity.to_f * price.to_f
    }
  end
  
  def shipped
    # if self.line_item_shipments
    #   total = 0
    #   self.line_item_shipments.each {|i| total += i.quantity_shipped }
    #   total == quantity
    # else
    #   false
    # end
    # OrderLineItem.joins(:line_item_shipments).where("line_item_shipments.order_line_item_id = ?", self.id)
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_shipped"]) {
    #   LineItemShipment.where(:order_line_item_id => self.id).group(:order_line_item_id).sum(:quantity_shipped).inject(0) {|k, v| (k + v[1]) != 0 ? true : false }
    # }
    quantity_shipped == actual_quantity
  end
  
  def unshipped
    quantity_shipped != actual_quantity
  end
  
  def shipped_id
    id if shipped
  end
  
  def amount_shipped
    puts "----> Amount Shipped #{quantity_shipped.to_f} * #{price.to_f} = #{quantity_shipped.to_f * price.to_f}"
    quantity_shipped.to_f * price.to_f
  end
  
  def calculate_quantity_shipped
    if self.line_item_shipments
      total = 0
      self.line_item_shipments.each {|i| total += i.quantity_shipped }
      total
    end
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_shipped"]) {
      # LineItemShipment.where(:order_line_item_id => self.id).group(:order_line_item_id).sum(:quantity_shipped).inject(0) {|sum, k| sum + k[1] }
    # }
  end
  
  def fulfilled
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_fulfilled"]) {
    #   if self.line_item_fulfillments
    #     total = 0
    #     self.line_item_fulfillments.each {|i| total += i.quantity_fulfilled }
    #     total == quantity
    #   else
    #     false
    #   end
    #    # LineItemFulfillment.where(:order_line_item_id => self.id).group(:order_line_item_id).sum(:quantity_fulfilled).inject(0) {|k, v| (k + v[1]) != 0 ? true : false }
    #  }
    quantity_fulfilled == actual_quantity
  end
  
  def unfulfilled
    quantity_fulfilled != actual_quantity
  end
  
  def fulfilled_id
    id if fulfilled
  end
  
  def amount_fulfilled
    quantity_fulfilled.to_f * price.to_f
  end
  
  def calculate_quantity_fulfilled
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}_quantity_fulfilled"]) {
      # if self.line_item_fulfillments
      #   total = 0
      #   self.line_item_fulfillments.each {|i| total += i.quantity_fulfilled }
      #   total
      # end
      LineItemFulfillment.where(:order_line_item_id => self.id).group(:order_line_item_id).sum(:quantity_fulfilled).inject(0) {|sum, k| sum + k[1] }
    # }
  end
  
end