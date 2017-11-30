#!/bin/bash
echo "#Cloudflare" > /etc/nginx/conf.d/00_real_ip_cloudflare_00.conf;
iptables -F cloudflare;
iptables -N cloudflare;
for ip in `curl https://www.cloudflare.com/ips-v4`; do
        iptables -A cloudflare -I INPUT -p tcp -m multiport --dports http,https -s "$ip" -j ACCEPT;
        echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/00_real_ip_cloudflare_00.conf;
done

ip6tables -F cloudflare;
ip6tables -N cloudflare;
for ip in `curl https://www.cloudflare.com/ips-v6`; do
        ip6tables -A cloudflare -I INPUT -p tcp -m multiport --dports http,https -s "$ip" -j ACCEPT;
        echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/00_real_ip_cloudflare_00.conf;
done

echo "real_ip_header CF-Connecting-IP;" >> /etc/nginx/conf.d/00_real_ip_cloudflare_00.conf;

#Debian/Ubuntu
iptables-save > /etc/iptables/rules.v4;
ip6tables-save > /etc/iptables/rules.v6;

#RHEL/CentOS
#iptables-save > /etc/sysconfig/iptables;
#ip6tables-save > /etc/sysconfig/ip6tables;
