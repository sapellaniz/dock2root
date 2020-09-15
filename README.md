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
Al lanzar el contenedor levanta un proxy para poder acceder a los servicios web de las máquinas de HTB con solo configurar nuestro navegador para que use el proxy (172.17.0.2:3128).

Si se lanza el contenedor bindeando un volumen que contenga el archivo de configuración de openVPN (docker run -v) el contenedor se conecta automáticamente a HTB para poder "lanzar y jugar".



