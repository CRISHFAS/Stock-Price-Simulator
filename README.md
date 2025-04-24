## Stock-Price-Simulator

En este proyecto crearemos un monitor de precios de acciones en tiempo real utilizando Mojolicious, un framework web moderno y potente para Perl. Este proyecto demostrará el poder de WebSockets en la comunicación en tiempo real. Simularemos precios de acciones de empresas populares como APPL, GOOGLE y AMZN, actualizando los precios directamente en la página web.

### Prerrequisitos

Antes de empezar, asegúrate de cumplir con lo siguiente:

- Tener Perl instalado en tu sistema.
- Tener Mojolicious instalado. 

Para instalarlo con CPAN, ejecuta el comando:

```bash
cpan Mojolicious
```
<br>

#### ¿Qué son los WebSockets?
Los WebSockets son una tecnología que permite un canal de comunicación bidireccional y en tiempo real entre un cliente (como un navegador) y un servidor. A diferencia del modelo clásico de solicitudes HTTP, los WebSockets mantienen una conexión persistente, lo que permite enviar datos sin necesidad de realizar solicitudes continuas.

#### Beneficios de los WebSockets:

- **Actualizaciones instantáneas**: El servidor puede enviar datos en cuanto estén disponibles.

- **Baja latencia**: No es necesario abrir y cerrar conexiones repetidamente.

- **Mayor eficiencia**: Menor sobrecarga en comparación con las solicitudes HTTP tradicionales.

#### Cómo funcionan los WebSockets?

![](https://tiagomelo.info/assets/images/2024-09-05-perl-mojolicious-ws-server/websockets.png)

- **Establecimiento de conexión**: El cliente solicita un enlace WebSocket al servidor. Si el servidor lo soporta, responde y se crea una conexión persistente.

- **Intercambio de datos**: Cliente y servidor pueden enviar y recibir mensajes directamente a través de esta conexión.

- **Cierre de conexión**: La conexión se mantiene hasta que el cliente o servidor deciden cerrarla. Este comportamiento es ideal para aplicaciones en tiempo real.

#### Configuración del Proyecto

Generaremos nuestra aplicación Mojolicious con el comando:

```bash
mojo generate app StockMonitor
```
<br>

Esto generará una estructura de directorios básica para la aplicación. Por ejemplo:

```plaintext
StockMonitor/
├── lib/
│   └── StockMonitor/
│       ├── Controller/
│       │   └── Example.pm
│       └── StockMonitor.pm
├── script/
│   └── stock_monitor
├── templates/
│   └── example/
├── public/
└── t/
```
<br>

**Limpieza inicial**:
Podemos eliminar archivos innecesarios para nuestro proyecto:

```bash
rm -f lib/StockMonitor/Controller/Example.pm
rm -rf templates/example/
```
<br>

Después, tu estructura debería lucir así:

```plaintext
StockMonitor/
├── lib/
│   └── StockMonitor/
│       ├── Controller/
│       │   └── Stock.pm
│       └── StockMonitor.pm
├── script/
│   └── stock_monitor
├── templates/
│   └── stock/
│       └── index.html.ep
└── public/
```
<br>

#### Configurando la Aplicación

Archivo principal `(lib/StockMonitor/StockMonitor.pm)`:

En este archivo definiremos las rutas:

```perl
package StockMonitor;
use Mojo::Base 'Mojolicious', -signatures;

sub startup ($self) {
  my $r = $self->routes;

  # Ruta WebSocket para actualizaciones en tiempo real
  $r->websocket('/stock_updates')->to('stock#updates');

  # Ruta para servir la página principal
  $r->get('/')->to('stock#index');
}

1;
```
<br>

Ruta `/stock_updates`: Maneja las conexiones WebSocket.

Ruta `'/'`: Renderiza la página principal del monitor.

El Controlador `(lib/StockMonitor/Controller/Stock.pm)`:
Aquí se encuentra la lógica principal de la aplicación:

```perl
package StockMonitor::Controller::Stock;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::IOLoop;

# Acción para renderizar la página principal
sub index {
  my $self = shift;
  $self->render(template => 'stock/index');
}

# Acción para manejar WebSockets
sub updates {
  my $self = shift;
  my $ticker = $self->param('ticker') || 'APPL';

  # Temporizador para simular precios de acciones
  my $timer = Mojo::IOLoop->recurring(2 => sub {
    my $price = 100 + rand(50);  # Simula un precio aleatorio
    $self->send({json => {ticker => $ticker, price => sprintf("%.2f", $price)}});
  });

  # Limpieza al cerrar el WebSocket
  $self->on(finish => sub {
    Mojo::IOLoop->remove($timer);
  });
}

1;
```
<br>

El Front-End `(templates/stock/index.html.ep)`:
Esta es la interfaz del usuario con actualizaciones en tiempo real:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Monitor de Precios de Acciones</title>
    <script>
      let socket;

      function connectToTicker() {
        const ticker = document.getElementById('ticker').value;
        if (socket && socket.readyState === WebSocket.OPEN) {
          socket.close();
        }

        socket = new WebSocket("<%= url_for('stock_updates')->to_abs %>?ticker=" + ticker);

        socket.onmessage = function(event) {
          const data = JSON.parse(event.data);
          document.getElementById('price').innerText = data.price;
          document.getElementById('ticker-display').innerText = data.ticker;
        };

        socket.onopen = function() { console.log('Conexión abierta: ' + ticker); };
        socket.onclose = function() { console.log('Conexión cerrada'); };
        socket.onerror = function(error) { console.error('Error:', error); };
      }

      window.onload = function() {
        connectToTicker();
      };
    </script>
  </head>
  <body>
    <h1>Monitor de Precios de Acciones</h1>
    <select id="ticker" onchange="connectToTicker()">
      <option value="APPL">APPL</option>
      <option value="GOOGLE">GOOGLE</option>
      <option value="AMZN">AMZN</option>
      <option value="MSFT">MSFT</option>
    </select>
    <p>Precio actual de <span id="ticker-display">APPL</span>: $<span id="price">-</span></p>
  </body>
</html>
```
<br>

#### Ejecutando la Aplicación
**Ejecuta el servidor con Morbo**:

```bash
morbo script/stock_monitor
```
<br>

Abre `http://127.0.0.1:3000` en tu navegador para interactuar con la aplicación.

![](https://tiagomelo.info/assets/images/2024-09-05-perl-mojolicious-ws-server/stockMonitor.gif)

### conclusión

Este proyecto demuestra cómo crear un monitor de precios de acciones en tiempo real utilizando [Mojolicious](https://www.mojolicious.org/), aprovechando [WebSockets](https://en.wikipedia.org/wiki/WebSocket) para actualizaciones de datos instantáneas. Aunque en este ejemplo se utilizan datos simulados, se pueden aplicar los mismos principios para crear una aplicación más compleja y realista. Con la sintaxis sencilla y las potentes funciones de Mojolicious, la creación de aplicaciones web en tiempo real en [Perl](https://www.perl.org/) se convierte en una experiencia agradable.

Descargar el código fuente
[Aquí](https://github.com/CRISHFAS/Stock-Price-Simulator)