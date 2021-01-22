#!/bin/bash
echo "Limpiando reglas anteriores..."
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
echo "Estableciendo politicas por defecto..."
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
echo "Habilitando bucle local..."
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
echo "Habilitando IP local..."
iptables -A INPUT -s 192.168.112.146 -j ACCEPT
iptables -A OUTPUT -d 192.168.112.146 -j ACCEPT
iptables -A INPUT -s 192.168.1.1 -j ACCEPT
iptables -A OUTPUT -d 192.168.1.1 -j ACCEPT
iptables -A INPUT -s 192.168.2.1 -j ACCEPT
iptables -A OUTPUT -d 192.168.2.1 -j ACCEPT
echo "Habilitando SSH..."
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --sport 22 -m state --state RELATED,ESTABLISHED -j ACCEPT
echo "Habilitando enrutamiento..."
echo "1" > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
echo "Habilitando redireccion al servidor Web..."
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 80 -j DNAT --to 192.168.2.2:80
iptables -A FORWARD -i enp0s3 -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A FORWARD -o enp0s3 -p tcp -m tcp --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT
echo "Habilitando salida a servidores DNS"
iptables -A FORWARD -o enp0s3 -p udp -m udp --dport 53 -j ACCEPT
iptables -A FORWARD -i enp0s3 -p udp -m udp --sport 53 -j ACCEPT
echo "Habilidando acceso desde DMZ a BBDD interna..."
iptables -A FORWARD -s 192.168.2.2 -d 192.168.1.2 -p tcp --dport 3306 -j ACCEPT
iptables -A FORWARD -s 192.168.1.2 -d 192.168.2.2 -p tcp --sport 3306 -j ACCEPT
echo "Habilitando salida red local a internet..."
iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -m state --state RELATED,ESTABLISHED -j ACCEPT
echo "Habilitando acceso al servidor Web desde la red local..."
iptables -A FORWARD -i enp0s8 -o enp0s9 -d 192.168.2.2 -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i enp0s9 -o enp0s8 -s 192.168.2.2 -p tcp -m tcp --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT
echo "Hablitando acceso a ssh para poder documentar practica...(debug mode)"
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -m state --state RELATED,ESTABLISHED -j ACCEPT
