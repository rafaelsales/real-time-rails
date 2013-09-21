RealTimeRails::Application.routes.draw do
  root controller: :auction, action: :index

  controller :auction do
    get 'connect', action: :connect
    post 'new_product', action: :new_product
    patch 'sell', action: :sell
    get 'auctioneer', action: :auctioneer
  end
end
