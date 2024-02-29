#!/bin/bash

# SISTEMA OPERATIVO
arch=$(uname -a)

# NUMERO DE NÚCLEOS FÍSICOS
cpuf=$(grep -c "physical id" /proc/cpuinfo)

# NUMERO DE CPU VIERTUALES
cpuv=$(grep -c "processor" /proc/cpuinfo)

# USO Y DISPONIBILIDAD DE LA MEMORIA RAM
read ram_total ram_use ram_percent <<< $(free --mega | awk '$1 == "Mem:" {printf "%d %d %.2f", $2, $3, $3/$2*100}')

# USO Y DISPONIBILIDAD DEL ESPACIO EN EL DISCO
read disk_total disk_use disk_percent <<< $(df -m --total | awk '$1 == "total" {printf "%d %d %d", $2/1024, $3, $3/$2*100}')

# CPU LOAD
cpu_fin=$(printf "%.1f" $(expr 100 - $(vmstat 1 2 | tail -1 | awk '{print $15}')))

# ULTIMO REINICIO
lb=$(who -b | awk '$1 == "arranque" {print $4 " " $5}')

# USO DE LVM
lvmu=$(if lsblk | grep -q "lvm"; then echo yes; else echo no; fi)

# CONEXIONES TCP
tcpc=$(ss -ta | grep -c ESTAB)

# USUARIOS
ulog=$(users | wc -w)

# DIRECCIONES IPv4 Y MAC
ip=$(hostname -I)
mac=$(ip link | awk '/link\/ether/ {print $2}')

# COMANDOS EJECUTADOS CON SUDO
cmnd=$(journalctl _COMM=sudo | grep -c COMMAND)

wall "	Architecture: $arch
	CPU physical: $cpuf
	vCPU: $cpuv
	Memory Usage: $ram_use/${ram_total}MB ($ram_percent%)
	Disk Usage: $disk_use/${disk_total}GB ($disk_percent%)
	CPU load: $cpu_fin%
	Last boot: $lb
	LVM use: $lvmu
	Connections TCP: $tcpc ESTABLISHED
	User log: $ulog
	Network: IP $ip ($mac)
	Sudo: $cmnd cmd"
