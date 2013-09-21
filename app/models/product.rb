class Product
  include ActiveModel::Model

  attr_accessor :title, :image, :high_bid, :high_bidder, :sold

  def initialize(attributes={})
    super
    @high_bid ||= 0
    @sold ||= false
  end

  def sold?
    sold
  end
end
