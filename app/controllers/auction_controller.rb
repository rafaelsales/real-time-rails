class AuctionController < ApplicationController
  include Tubesock::Hijack

  def index
  end

  def connect
    hijack do |tubesock|
      sockets << tubesock

      tubesock.onopen do
        logger.debug "New user connected: #{tubesock.inspect}"
      end

      tubesock.onmessage do |data|
        message = JSON.parse(data)
        logger.debug "New message: #{message.inspect}"

        case message['event']
        when 'user_joined'
          @username = message['username']
          if product
            tubesock.send_data JSON.dump(event: 'update_product', product: product.as_json)
          end
        when 'bid_increment'
          semaphore.synchronize do
            product.high_bid += message['amount'].to_i unless product.sold?
            product.high_bidder = @username
          end

          send_data_to_all JSON.dump(event: 'product_bidded',
                                     bidder: @username,
                                     amount: product.high_bid)
        end
      end
    end
  end

  def auctioneer
  end

  def new_product
    self.product = Product.new params['product']

    send_data_to_all JSON.dump(event: 'update_product', product: product.as_json)
    redirect_to action: :auctioneer
  end

  def sell
    semaphore.synchronize do
      product.sold = true
    end

    send_data_to_all JSON.dump(event: 'product_sold', product: product.as_json)
    redirect_to action: :auctioneer
  end

  private

  def send_data_to_all(message)
    sockets.each do |socket|
      logger.debug 'Sending: ' + message
      socket.send_data(message)
    end
  end

  def sockets
    @@sockets ||= []
    @@sockets.delete_if { |socket| socket.instance_variable_get('@socket').closed? }
    @@sockets
  end

  def semaphore
    @@semaphore ||= Mutex.new
  end

  def product
    defined?(@@product) ? @@product : nil
  end

  def product=(product)
    @@product = product
  end
end
