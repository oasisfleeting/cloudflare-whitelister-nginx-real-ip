#!/bin/bash
echo "#Cloudflare" > /etc/nginx/conf.d/00_real_ip_cloudflare_00.conf;
        iptables -F cloudflare;
        iptables -N cloudflare;
for i in `curl https://www.cloudflare.com/ips-v4`; do
        iptables -A cloudflare -p tcp --sport 2408 -s $i -j ACCEPT;
        iptables -A cloudflare -p tcp -m multiport --dports http,https -s $i -j ACCEPT;
        echo "set_real_ip_from $i;" >> /etc/nginx/conf.d/00_real_ip_cloudflare_00.conf;
done

iptables-save > /etc/sysconfig/iptables
echo "real_ip_header CF-Connecting-IP;" >> /etc/nginx/conf.d/00_real_ip_cloudflare_00.conf;
