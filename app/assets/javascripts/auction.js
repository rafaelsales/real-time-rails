var Auction = (function() {
  var BIDS_LIST_SIZE = 6;
  var connection;

  var connect = function(username, wsocket_url) {
    connection = new WebSocket(wsocket_url);

    connection.onopen = function() {
      connection.send(JSON.stringify({ event: 'user_joined',
                                       username: username }));
    };

    connection.onmessage = function(e) {
      var msg = JSON.parse(e.data);
      console.log(msg);

      switch(msg.event) {
        case 'update_product':
          $('#product_title').text(msg.product.title);
          $('#product_image').attr('src', msg.product.image);
          $('#bids li').remove();
          renderHighBid(msg.product.high_bid, msg.product.high_bidder);
          Loading.hide();

          break;
        case 'product_bidded':
          renderHighBid(msg.amount, msg.bidder);
          renderBidHistoryEntry(msg);

          break;
        case 'product_sold':
          var product = msg.product
          alert(product.title + "\n" +
                "sold to " + product.high_bidder + "\n" +
                "for $" + product.high_bid);
          Loading.show();

          break;
        default:
          console.log("Event '" + msg.event + "' unknown");
      }
    };
  }

  var renderHighBid = function(high_bid, high_bidder) {
    $('#high_bid').text(high_bid);
    $('#high_bidder').text(high_bidder);
  };

  var renderBidHistoryEntry = function(msg) {
    var bidsList = $('#bids');
    bidsList.find('li').eq(BIDS_LIST_SIZE - 1).remove();
    bidsList.prepend($.Mustache.render('bid-event', msg));
  };

  var initialize = function() {
    $('#bid_buttons button').on('click', function() {
      connection.send(JSON.stringify({ event: 'bid_increment', amount: $(this).val() }));
    });
  };

  var connection = function() {
    return connection;
  };

  return {
    initialize: initialize,
    connect: connect,
    connection: connection
  };
})();
