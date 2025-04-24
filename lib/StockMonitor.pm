# Copyright (c) 2024 Tiago Melo. All rights reserved.
# Use of this source code is governed by the MIT License that can be found in
# the LICENSE file.

package StockMonitor;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {

  # Router
  my $r = $self->routes;

  # WebSocket route for real-time updates
  $r->websocket('/stock_updates')->to('stock#updates');

  # Normal route to serve the main page
  $r->get('/')->to('stock#index');
}

1;
