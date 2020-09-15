# Dock2rooT

Contenedor diseñado para CTF del tipo "boot to root".
Basado en el proyecto [Offensive Docker](https://github.com/aaaguirrep/offensive-docker) de Arsenio Aguirre.

## Build:
```
git clone https://gitlab.com/sapellaniz/dock2root.git
cd dock2root
sudo docker build -t dock2root .
```

## Run:
```
sudo docker run --rm -it -h Dock2rooT -v /pc/path:/container/path --cap-add=NET_ADMIN --device=/dev/net/tun --sysctl net.ipv6.conf.all.disable_ipv6=0 --name d2r dock2root /bin/zsh
```

## How-To:
### Servicios web de las máquinas:

Al lanzar el contenedor levanta un proxy para poder acceder a los servicios web de las máquinas de HTB con solo configurar nuestro navegador para que use el proxy (172.17.0.2:3128).

### Burp Suite:

Se puede usar Burp Suite facilmente, solo tenemos que configurar en la herramienta (ultima versión 2020.9.1): "User options"->"Connections"->"Upstream Proxy Servers"->"Add" y se añade el proxy del contenedor (172.17.0.2:3128) para cualquier destino "*".  Como siempre, hay que configurar el navegador para que use Burp. [Upstream proxy](https://portswigger.net/support/burp-suite-upstream-proxy-servers)

### Lanza y juega:

Si se lanza el contenedor bindeando un volumen que contenga el archivo de configuración de openVPN (docker run -v) el contenedor se conecta automáticamente a HTB para poder "lanzar y jugar" sin tener que preocuparse de configurar nada.



