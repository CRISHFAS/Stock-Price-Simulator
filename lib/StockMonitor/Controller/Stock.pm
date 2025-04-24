# Copyright (c) 2024 Tiago Melo. All rights reserved.
# Use of this source code is governed by the MIT License that can be found in
# the LICENSE file.

package StockMonitor::Controller::Stock;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::IOLoop;

# Action to render the main page
sub index {
  my $self = shift;
  $self->render(template => 'stock/index');
}

# WebSocket action to handle real-time updates
sub updates {
  my $self = shift;

  # Get the stock ticker from the query parameter
  my $ticker = $self->param('ticker') || 'APPL';

  # Set up a timer to simulate stock price updates
  my $timer = Mojo::IOLoop->recurring(2 => sub {
    my $price = 100 + rand(50);  # Simulate a random stock price
    $self->send({json => {ticker => $ticker, price => sprintf("%.2f", $price)}});
  });

  # Clean up when WebSocket is closed
  $self->on(finish => sub {
    Mojo::IOLoop->remove($timer);
  });
}

1;