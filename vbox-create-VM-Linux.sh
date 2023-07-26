#!/bin/bash

# By Krh3rtz 2018

# This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
 
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Nombre de la máquina
nom_maq="";

# NIC del host a utilizar eg. eth0
real_nic="";

# Modo en que funcionará la tarjeta de red
nic_mode="bridged";

# Tamaño de RAM en Mb
ram_size="";

# Ruta de iso del OS
iso_ruta="";

# true = necesitamos que funcione el servidor vrde. 
# false = que no se active el vrde;
vrde_status=true;

# Tamaño de disco en Mb
tam_disco="";

# Memoria virtual a asignar (normalmente 128 Mb)
vir_ram="128";

# SO a utilizar
# Para ver los diferentes SO disponibles en virtualbox
# vboxmanage list ostypes
# eg. Ubuntu_64
os_type="";

# Carpeta principal para almacenar todas las máquinas virtuales
contenedormvs_ruta="";


# Carpeta para almacenar el .vdi de la máquina a crear (en mayúsculas)
contenedormv_ruta=$contenedormvs_ruta${nom_maq^^}"/";

# Creación de contenedor y carpeta de almacenaje de .vdi
mkdir -p $contenedormv_ruta;

# Ruta completa de .vdi a utilizar
vdi_ruta=$contenedormv_ruta$nom_maq.vdi;

# Crear la máquina virtual y registrarla
vboxmanage createvm --name $nom_maq --ostype $os_type --register;

# Agregar memoria RAM, soporte ACPI, prioridad 1 de booteo al DVD, parámetros de red
vboxmanage modifyvm $nom_maq --memory $ram_size --vram $vir_ram --acpi on --boot1 dvd --nic1 $nic_mode --bridgeadapter1 $real_nic;

# Crear un disco duro con tamaño especificado y ruta de almacenaje
vboxmanage createhd --filename $vdi_ruta --size $tam_disco;

# Agregar el tipo de tecnología para que utilice el disco, en este caso es SATA
vboxmanage storagectl $nom_maq --name "SATA Controller" --add sata --controller IntelAHCI;

# Añadir el disco .vdi creado al "slot" la máquina virtual
vboxmanage storageattach $nom_maq --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vdi_ruta;

# Agregar controladora de tipo IDE para iso a montar
vboxmanage storagectl $nom_maq --name "IDE Controller" --add ide;

# Le indicamos a nuestra VM que agregaremos el iso para que arranque con el.
vboxmanage storageattach $nom_maq --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $iso_ruta;
# Para desmontar la iso
#vboxmanage storageattach $nom_maq --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium none;




# En caso de querer administrar nuestra VM utilizando una conexión remota
# es posible activar la bandera de vrde, que es un parámetro de Vbox que permite
# administrar la máquina virtual con utilizando el protocolo RDP.

if [ $vrde_status == true ];
then
	vboxmanage modifyvm $nom_maq --vrde on;
	echo "[+] Se ha habilitado el servicio vrde en la máquina virtual	: $nom_maq";
	echo " Para inicializar $nom_maq en modo headless utilice el comando:";
	echo " vboxheadless --startvm $nom_maq &";
else
	echo "[*] En caso de querer habilitar el servicio vrde  en el equipo $nom_maq, utilice el comando: ";
	echo "VBoxManage modifyvm $nom_maq --vrde on";
fi

