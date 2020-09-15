# Dock2rooT
Contenedor diseñado para CTF del tipo "boot to root".
Basado en el proyecto [Offensive Docker](https://github.com/aaaguirrep/offensive-docker) de Arsenio Aguirre.

## 1- Características
### Lanza y juega:
Si se lanza el contenedor bindeando un volumen que contenga el archivo de configuración de openVPN (docker run -v) el contenedor se conecta automáticamente a HTB para poder "lanzar y jugar" sin tener que preocuparse de configurar nada.

### Seguro:
Si jugando desde una máquina virtual no tienes porque ser root, desde un contenedor tampoco, al levantar el contenedor apareces como "playerRed", un usuario con los privilegios mínimos necesarios para poder jugar.

### Ligero:
Todas las herramientas necesarias para poder jugar... y mas! Enmarcadas en una imágen de menos de 5GB que lanza el contenedor en menos de 1 segundo. Si quieres añadir alguna solo tienes que editar el dockerfile y reconstruir o ponerte en contacto conmigo, las sugerencias son bienvenidas :)

### Usabilidad:
Al lanzar el contenedor se crea una sesión de tmux en la que podrás crear paneles y ventanas para poder realizar varias tareas a la vez, los atajos del teclado se pueden ver en "~/.tmux.conf", también hay tres funciones en "~/.zshrc" para automatizar un el escaneo de puertos inicial y poder ir más rápido.

## 2- Instalar:
**Desde gitlab**
```
git clone https://gitlab.com/sapellaniz/dock2root.git
cd dock2root
sudo docker build -t dock2root .
```
**Desde dockerhub**
```

```

## 3- Lanzar:
```
sudo docker run --rm -it -h Dock2rooT -v /pc/path:/container/path --cap-add=NET_ADMIN --device=/dev/net/tun --sysctl net.ipv6.conf.all.disable_ipv6=0 --name d2r dock2root /bin/zsh
```

## 4- FAQs:
### Servicios web de las máquinas:
Al lanzar el contenedor se levanta un proxy para poder acceder a los servicios web de las máquinas de HTB con solo configurar el navegador para que use el proxy (172.17.0.2:3128).

### Burp Suite:
Se puede usar Burp Suite facilmente, solo hay que configurar en la herramienta (ultima versión 2020.9.1): "User options"->"Connections"->"Upstream Proxy Servers"->"Add" y añadir el proxy del contenedor (172.17.0.2:3128) para cualquier destino "*".  Como siempre, hay que configurar el navegador para que use Burp. [Upstream proxy](https://portswigger.net/support/burp-suite-upstream-proxy-servers)

## 5- Seguridad
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