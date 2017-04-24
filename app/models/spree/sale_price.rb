module Spree
  class SalePrice < ActiveRecord::Base
    include Spree::CalculatedAdjustments

    belongs_to :price, class_name: "Spree::Price", touch: true
    delegate :currency, to: :price, allow_nil:true

    has_one :variant, through: :price

    # has_one :calculator, class_name: "Spree::Calculator", as: :calculable, dependent: :destroy
    # validates :calculator, presence: true
    # accepts_nested_attributes_for :calculator

    scope :active, -> { where(enabled: true).where('(start_at <= now() OR start_at IS NULL) AND (end_at >= now() OR end_at IS NULL)') }

    before_destroy :touch_product

    extend DisplayMoney
    money_methods :calculated_price
    alias_method :money, :display_calculated_price

    def calculated_price
      calculator.compute self
    end

    def enable
      update_attribute(:enabled, true)
    end

    def disable
      update_attribute(:enabled, false)
    end

    def active?
      Spree::SalePrice.active.include? self
    end

    def start(end_time = nil)
      end_time = nil if end_time.present? && end_time <= Time.now # if end_time is not in the future then make it nil (no end)
      attr = { end_at: end_time, enabled: true }
      attr[:start_at] = Time.now if self.start_at.present? && self.start_at > Time.now # only set start_at if it's not set in the past
      update_attributes(attr)
    end

    def stop
      update_attributes({ end_at: Time.now, enabled: false })
    end

    # Convenience method for displaying the price of a given sale_price in the table
    def display_price
      Spree::Money.new(value || 0, { currency: price.currency })
    end

    protected
    def touch_product
      self.variant.product.touch
    end
  end
end
