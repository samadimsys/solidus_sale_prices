class Spree::Calculator::FixedAmountSalePriceCalculator < Spree::Calculator
  def self.description
    "Fixed amount sale price"
  end

  def compute(object)
    object.value
  end
end
