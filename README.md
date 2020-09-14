# Dock2rooT

Contenedor diseñado para CTF del tipo "boot to root".
Basado en el proyecto [Offensive Docker](https://github.com/aaaguirrep/offensive-docker) de Arsenio Aguirre.

## Build:
```
git clone https://gitlab.com/sapellaniz/dock2root.git
cd dock2root
docker build -t dock2root .
```

## Run:
```
 docker run -d -it -h Dock2rooT -name d2r -v /pc/path:/docker/path \
 --cap-add=NET_ADMIN --device=/dev/net/tun --sysctl net.ipv6.conf.all.disable_ipv6=0 dock2root
 ssh root@172.17.0.2 -t tmux a
```