# Dock2rooT
Contenedor diseñado para CTF del tipo "boot to root".
Basado en el proyecto [Offensive Docker](https://github.com/aaaguirrep/offensive-docker) de Arsenio Aguirre.

## 1- Build:
```
git clone https://gitlab.com/sapellaniz/dock2root.git
cd dock2root
sudo docker build -t dock2root .
```

## 2- Run:
```
sudo docker run --rm -it -h Dock2rooT -v /pc/path:/container/path --cap-add=NET_ADMIN --device=/dev/net/tun --sysctl net.ipv6.conf.all.disable_ipv6=0 --name d2r dock2root /bin/zsh
```

## 3- How-To:
### Lanza y juega:
Si se lanza el contenedor bindeando un volumen que contenga el archivo de configuración de openVPN (docker run -v) el contenedor se conecta automáticamente a HTB para poder "lanzar y jugar" sin tener que preocuparse de configurar nada.

### Servicios web de las máquinas:
Al lanzar el contenedor levanta un proxy para poder acceder a los servicios web de las máquinas de HTB con solo configurar nuestro navegador para que use el proxy (172.17.0.2:3128).

### Burp Suite:
Se puede usar Burp Suite facilmente, solo tenemos que configurar en la herramienta (ultima versión 2020.9.1): "User options"->"Connections"->"Upstream Proxy Servers"->"Add" y se añade el proxy del contenedor (172.17.0.2:3128) para cualquier destino "*".  Como siempre, hay que configurar el navegador para que use Burp. [Upstream proxy](https://portswigger.net/support/burp-suite-upstream-proxy-servers)

## 4- Security
La 5ª regla de HTB:
```
5) Dont use your production PC to connect to HTB Network 
We strongly recommend not to use your production PC to connect to the HTB Network. Build a VM or physical system just for this purpose.
HTB Network is filled with security enthusiasts that have the skills and toolsets to hack systems and no matter how hard we try to secure
you, we are likely to fail :P We do not hold any responsibility for any damage, theft or loss of personal data although in such event,
we will cooperate fully with the authorities. 
```
Estas son unas recomendaciones para ponerselo más dificil a "los malos":

- Configurar nftables para evitar conexiones entrantes, incluido ping. Tambien puede usarse para evitar conexiones entre el contenedor y máquinas de la red local.

- Lanzar el contenedor con la opción "--rm" evita persistencia de posible malware.

- El reenvio de paquetes debe estar habilitado para poder jugar, es recomendable tenerlo desactivado por defecto y solamente activarlo para jugar.

- Crear una partición dedicada para HTB o CTFs, con las opciones nosuid,nodev,noexec en fstab.